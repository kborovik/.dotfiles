# Fish completions for grok — delegated to the installed binary so they
# stay in sync without vendoring a large clap_complete dump.
# (acu/leadpilot/mailpilot use Click's _*_COMPLETE protocol; grok is clap.)
if command -q grok
    grok completions fish 2>/dev/null | source
end
