#!/bin/bash

RESULT=$(go list -u -mod=readonly -m -f '
{{if not .Indirect}}
    {{if .Replace}}
        {{if .Replace.Update}}
            {{.}}
        {{end}}
    {{else}}
        {{if .Update}}
            {{.}}
        {{end}}
    {{end}}
{{end}}' all | sed -r 's/^\s*//;/^$/d')

echo
echo
echo "Result before filtering ignored dependencies:"
echo "$RESULT"
echo
echo


while read line ; do
    if [ "$line" != "" ]
    then
        echo "$line is ignored"
        DEP_TO_IGNORE=$(echo "$line" | sed -r 's|/|\\/|g')
        NEW_RESULT=$(echo "$RESULT" | sed -r '/^'"$DEP_TO_IGNORE"'\s.*/d')
        RESULT=$NEW_RESULT
    fi
done < <(echo "$IGNORED_DEPENDENCIES")

if [ -n "$RESULT" ]
then
    echo "There is some outdated dependencies:"
    echo "$RESULT"

    RESULT="${RESULT//'%'/'%25'}"
    RESULT="${RESULT//$'\n'/'%0A'}"
    RESULT="${RESULT//$'\r'/'%0D'}"
    echo "::set-output name=is-up-to-date::false"
    echo "::set-output name=outdated::$RESULT"
    echo "There is some outdated dependencies:"
    echo "$RESULT"
else
    echo "::set-output name=is-up-to-date::true"
fi

