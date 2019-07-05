GIT_EXTERNAL_DIFF=./diff.ros git diff > diff.diff
cat diff.diff | grep -A 1 -B 1 'new|'
