

PlistFile="$1"
Keys=("${!2}")
dumyValue="$3"
Values=("${!4}")

#Print variables
echo -----------------------------
echo PlistFile = $PlistFile
echo "Keys   are: ${Keys[@]} "
echo "Values are: ${Values[@]}"
echo -----------------------------




/usr/libexec/PlistBuddy -c "Delete :provisioningProfiles" "$PlistFile"
/usr/libexec/PlistBuddy -c "Add :provisioningProfiles dict" "$PlistFile"

arraylength=${#Keys[@]}

for (( i=1; i<${arraylength}+1; i++ ));
do
currentKey=${Keys[$i-1]}
currentValue=${Values[$i-1]}
/usr/libexec/PlistBuddy -c "Add :provisioningProfiles:$currentKey string $currentValue"  "$PlistFile"
done
