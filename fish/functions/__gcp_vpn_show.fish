function __gcp_vpn_show
    argparse h/help -- $argv
    or return 1

    if set -q _flag_help
        echo "Usage: gcp vpn show <PROJECT_ID> <REGION>"
        echo
        echo "Show VPN configuration details for a project and region"
        echo
        echo "Displays comprehensive VPN information including:"
        echo "  - VPN gateway details (name, network, IP addresses)"
        echo "  - Tunnel status and configuration"
        echo "  - Cloud Router info (ASN, BGP peers, advertised routes)"
        echo "  - Imported and exported routes"
        echo
        echo "Arguments:"
        echo "  PROJECT_ID    GCP project ID (required)"
        echo "  REGION        GCP region (required, e.g., us-central1)"
        echo
        echo "Options:"
        echo "  -h, --help    Show this help message"
        echo
        echo "Examples:"
        echo "  gcp vpn show my-project us-central1"
        echo "  gcp vpn show my-project europe-west1"
        return 0
    end

    set -l project_id $argv[1]
    set -l region $argv[2]

    if test -z "$project_id"
        echo "Error: PROJECT_ID is required" >&2
        echo "Run 'gcp vpn show --help' for usage information" >&2
        return 1
    end

    if test -z "$region"
        echo "Error: REGION is required" >&2
        echo "Run 'gcp vpn show --help' for usage information" >&2
        return 1
    end

    if not command -v jq >/dev/null 2>&1
        echo "Error: jq is required but not installed" >&2
        echo "Install with: brew install jq" >&2
        return 1
    end

    # Get VPN Gateways
    set -l gateways_json (gcloud compute vpn-gateways list \
        --project="$project_id" \
        --filter="region:$region" \
        --format=json 2>/dev/null)

    if test -z "$gateways_json" -o "$gateways_json" = "[]"
        echo "No VPN gateways found in $region"
        return 0
    end

    # Get VPN Tunnels
    set -l tunnels_json (gcloud compute vpn-tunnels list \
        --project="$project_id" \
        --filter="region:$region" \
        --format=json 2>/dev/null)

    # Get Cloud Routers
    set -l routers_json (gcloud compute routers list \
        --project="$project_id" \
        --filter="region:$region" \
        --format=json 2>/dev/null)

    # Process each gateway and group all related info under it
    for gateway in (echo "$gateways_json" | jq -r '.[].name')
        set -l gateway_data (echo "$gateways_json" | jq -r ".[] | select(.name == \"$gateway\")")
        set -l network (echo "$gateway_data" | jq -r '.network | split("/") | last')

        echo "=== VPN Gateway: $gateway ($project_id / $region) ==="
        echo "Network: $network"
        echo "IP Addresses:"
        echo "$gateway_data" | jq -r '.vpnInterfaces[] | "  Interface \(.id): \(.ipAddress)"'
        echo

        # Tunnels for this gateway
        echo "Tunnels:"
        set -l gateway_tunnels (echo "$tunnels_json" | jq -r ".[] | select(.vpnGateway | contains(\"/$gateway\"))")
        if test -n "$gateway_tunnels"
            echo "$gateway_tunnels" | jq -rs '.[] |
                "  \(.name)
Status: \(.status) (\(.detailedStatus // "N/A"))
Peer IP: \(.peerIp)
IKE Version: \(.ikeVersion)
Router: \(.router | split("/") | last)
Local Traffic Selector: \((.localTrafficSelector // []) | if length > 0 then join(", ") else "dynamic" end)
Remote Traffic Selector: \((.remoteTrafficSelector // []) | if length > 0 then join(", ") else "dynamic" end)"'
        else
            echo "  No tunnels found"
        end
        echo

        # Find router associated with this gateway's tunnels
        set -l router_name (echo "$gateway_tunnels" | jq -rs '.[0].router // empty | split("/") | last' 2>/dev/null)
        if test -n "$router_name"
            echo "Router: $router_name"

            # Get router details
            set -l router_detail (gcloud compute routers describe "$router_name" \
                --project="$project_id" \
                --region="$region" \
                --format=json 2>/dev/null)

            echo "$router_detail" | jq -r '
                "  ASN: \(.bgp.asn // "N/A")
  Advertise Mode: \(.bgp.advertiseMode // "DEFAULT")
  Advertised Groups: \(.bgp.advertisedGroups // ["none"] | join(", "))"'

            # Display Advertised IP Ranges as a list
            set -l ip_ranges (echo "$router_detail" | jq -r '.bgp.advertisedIpRanges[]?.range // empty' 2>/dev/null)
            if test -n "$ip_ranges"
                echo "  Advertised IP Ranges:"
                for range in $ip_ranges
                    echo "    $range"
                end
            else
                echo "  Advertised IP Ranges: none"
            end

            # Get BGP peers
            set -l bgp_peers (echo "$router_detail" | jq -r '.bgpPeers // []')
            if test "$bgp_peers" != "[]" -a "$bgp_peers" != null
                echo "  BGP Peers:"
                for peer_name in (echo "$bgp_peers" | jq -r '.[].name')
                    set -l peer_data (echo "$bgp_peers" | jq -r ".[] | select(.name == \"$peer_name\")")
                    set -l peer_asn (echo "$peer_data" | jq -r '.peerAsn')
                    set -l peer_ip (echo "$peer_data" | jq -r '.peerIpAddress')
                    set -l peer_advertise_mode (echo "$peer_data" | jq -r '.advertiseMode // "DEFAULT"')
                    echo "    $peer_name: ASN $peer_asn, IP $peer_ip"
                    # Show advertised IP ranges if peer has custom advertise mode
                    if test "$peer_advertise_mode" = "CUSTOM"
                        set -l peer_ip_ranges (echo "$peer_data" | jq -r '.advertisedIpRanges[]?.range // empty')
                        if test -n "$peer_ip_ranges"
                            echo "      Advertised IP Ranges:"
                            for range in $peer_ip_ranges
                                echo "        $range"
                            end
                        end
                    end
                end
            end

            # Get router status for BGP session details
            set -l router_status (gcloud compute routers get-status "$router_name" \
                --project="$project_id" \
                --region="$region" \
                --format=json 2>/dev/null)

            if test -n "$router_status"
                # BGP peer status
                set -l bgp_status (echo "$router_status" | jq -r '.result.bgpPeerStatus // []')
                if test "$bgp_status" != "[]" -a "$bgp_status" != null
                    echo "  BGP Session Status:"
                    echo "$bgp_status" | jq -r '.[] |
                        "    \(.name): \(.status) (Uptime: \(.uptime // "N/A"), Learned: \(.numLearnedRoutes // 0) routes)"'
                end

                # Exported routes (best routes going through VPN)
                set -l best_routes (echo "$router_status" | jq -r '.result.bestRoutes // []')
                if test "$best_routes" != "[]" -a "$best_routes" != null
                    set -l vpn_routes (echo "$best_routes" | jq -r '[.[] | select(.nextHopVpnTunnel != null) | .destRange] | unique | .[]')
                    if test -n "$vpn_routes"
                        echo "  Exported Routes:"
                        for route in $vpn_routes
                            echo "    $route"
                        end
                    end
                end

                # Imported routes (learned from peer)
                set -l best_routes_for_bgp (echo "$router_status" | jq -r '.result.bestRoutesForRouter // []')
                if test "$best_routes_for_bgp" != "[]" -a "$best_routes_for_bgp" != null
                    set -l imported_routes (echo "$best_routes_for_bgp" | jq -r '[.[].destRange] | unique | .[]')
                    if test -n "$imported_routes"
                        echo "  Imported Routes:"
                        for route in $imported_routes
                            echo "    $route"
                        end
                    end
                end
            end
        end
        echo
    end
end
