#!/use/bin/env bash

latest="https://updates.signal.org/android/latest.json"
 
fail()
{
    printf -- "oops: %s\n" "$*" >&2
    exit 1
}
 
json="$( curl -sS -- "$latest" )" || fail cannot get "$latest"
 
read -r sum url <<< "$( jq -j '.sha256sum," ",.url' <<< "$json")"
 
file="${url##*/}"
tmp="$file.part"
 
[[ -n $url || -n $file ]] || fail format of "$latest" has changed "?"
 
if [[ -f $file ]]
then
    sha256sum -c <<< "$sum $file" || fail checksum is wrong for existing file
 
elif curl -- "$url" > "$tmp"
then
    if ! sha256sum -c <<< "$sum $tmp"
    then
        rm -f -- "$tmp"
        fail checksum was wrong for new file
    fi
    rm -f -- Signal-website-universal-release-*.apk # clean up old versions
    mv -- "$tmp" "$file"
else
    fail cannot get "$file"
fi
