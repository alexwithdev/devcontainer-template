#!/usr/bin/env sh

set -e;
FAILED=0;
for url in \
  https://dv-g3b-emudhra.we-have-a-problem.com/ \
  https://dv-g3b-aaa-emudhra.we-have-a-problem.com/ \
  https://dv-g3b-noct-emudhra.we-have-a-problem.com/ \
  https://dv-g3c-emudhra.we-have-a-problem.com/ \
  https://ov-g3b-emudhra.we-have-a-problem.com/ \
  https://ov-g3c-emudhra.we-have-a-problem.com/ \
  https://ev-g3b-emudhra.we-have-a-problem.com/ \
  https://ev-g3c-emudhra.we-have-a-problem.com/ \
  https://dv-g3c-aaa-emudhra.we-have-a-problem.com/ \
  https://ov-g3b-aaa-emudhra.we-have-a-problem.com/ \
  https://ov-g3c-aaa-emudhra.we-have-a-problem.com/ \
  https://ev-g3b-aaa-emudhra.we-have-a-problem.com/ \
  https://ev-g3c-aaa-emudhra.we-have-a-problem.com/ \
  https://dv-g3b-aaa-noct-emudhra.we-have-a-problem.com/;
do
  echo -n "Testing $url ... ";
  set +e;
  curl -sS -o /dev/null --connect-timeout 10 --max-time 15 "$url";
  CODE=$?;
  set -e;
  if [ "$CODE" -eq 60 ]; then
    echo "Rejected by certificate error (OK, exit 60)";
  elif [ "$CODE" -eq 0 ]; then
    echo "ACCEPTED (BAD, exit 0)";
    FAILED=1;
  else
    echo "Rejected by other error (BAD, exit $CODE)";
    FAILED=1;
  fi;
done;
if [ "$FAILED" -eq 1 ]; then
  echo "FAILED: not all domains were rejected due to certificate problems";
  exit 1;
fi;
echo "PASSED: all four domains rejected due to certificate errors"