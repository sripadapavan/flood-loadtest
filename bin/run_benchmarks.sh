#!/bin/bash

here=${PWD}

function poll_and_report {
  echo Detailed results at https://flood.io/${flood_uuid}
  flood_status="queued"
  while [ "${flood_status}" != "finished" ]; do
    echo Polling ${flood_uuid} current status ${flood_status} ...
    flood_status=`/usr/bin/curl --silent --user ${FLOOD_API_TOKEN}: https://api.flood.io/floods/${flood_uuid} | /usr/local/bin/jq ".response.status" | tr -d '"'`
    sleep 3
  done

  # get verbose GC logs
  wget -O ${here}/benchmarks/results/gc/${flood_uuid}.log http://s1.node-production.flood.io/log/verbosegc.log

  flood_report=`/usr/bin/curl --silent --user ${FLOOD_API_TOKEN}: https://api.flood.io/floods/${flood_uuid}/report | /usr/local/bin/jq ".response.report" | tr -d '"'`
  apdex=`/usr/bin/curl --silent --user ${FLOOD_API_TOKEN}: https://api.flood.io/floods/${flood_uuid} | /usr/local/bin/jq ".response.apdex" | tr -d '"'`
  mean_response_time=`/usr/bin/curl --silent --user ${FLOOD_API_TOKEN}: https://api.flood.io/floods/${flood_uuid} | /usr/local/bin/jq ".response.mean_response_time" | tr -d '"'`

  echo >> ${here}/benchmarks/results/${flood_uuid}.md
  echo "### ${tool} ${threads} Users" >> ${here}/benchmarks/results/${flood_uuid}.md
  echo "#### https://flood.io/${flood_uuid}" >> ${here}/benchmarks/results/${flood_uuid}.md
  echo "#### Apdex ${apdex}" >> ${here}/benchmarks/results/${flood_uuid}.md
  echo "${flood_report}" >> ${here}/benchmarks/results/${flood_uuid}.md
  echo >> ${here}/benchmarks/results/${flood_uuid}.md

  rm -rf ~/VerboseGCAnalyzer-1.3/export/*
  cd ~/VerboseGCAnalyzer-1.3/bin
  ./start.sh /var/log/flood/verbosegc.log
  mv ~/VerboseGCAnalyzer-1.3/export/html_report ${here}/benchmarks/results/gc/${flood_uuid}
  echo "\![](./gc/${flood_uuid}/tenured_size.jpg)" >> ${here}/benchmarks/results/${flood_uuid}.md
  echo "\![](./gc/${flood_uuid}/collection_pause_time.jpg)" >> ${here}/benchmarks/results/${flood_uuid}.md
  echo "\![](./gc/${flood_uuid}/cpu_real.jpg)" >> ${here}/benchmarks/results/${flood_uuid}.md
  echo "\![](./gc/${flood_uuid}/promoted_size.jpg)" >> ${here}/benchmarks/results/${flood_uuid}.md
  echo "\![](./gc/${flood_uuid}/young_size.jpg)" >> ${here}/benchmarks/results/${flood_uuid}.md
  echo >> ${here}/benchmarks/results/${flood_uuid}.md

  echo "| [${threads} Users](https://flood.io/${flood_uuid}) [gc](./benchmarks/results/${flood_uuid}.md) | ${tool} | `date +"%F %T"` | $((duration/60)) mins | ${apdex} | ${mean_response_time} ms |" >> ${here}/README.md

  cd ~/flood-loadtest
  git add .
  git commit -am "Updating benchmarks from `date`"
  git push

  sudo rm /var/log/flood/verbosegc.log
}

sudo rm /var/log/flood/verbosegc.log

threads=100
rampup=10
duration=120

tag=benchmark

# # Benchmark Gatling Current 1.5.3
# tool="Gatling-1.5.3"
# flood_uuid=`/usr/bin/curl --silent --user ${FLOOD_API_TOKEN}: https://api.flood.io/floods \
# -F "region=ap-southeast-2" \
# -F "flood[tool]=gatling" \
# -F "flood[threads]=${threads}" \
# -F "flood[rampup]=${rampup}" \
# -F "flood[duration]=$((duration-rampup))" \
# -F "flood[name]=Gatling 1.5.3" \
# -F "flood[tag_list]=${tag}" \
# -F "flood[plan]=@${here}/benchmarks/spec/gatling/1.5.3/benchmark.scala" | /usr/local/bin/jq ".response.uuid" | tr -d '"'`
# poll_and_report

# # Benchmark JMeter Current 2.9
# tool="JMeter-2.9"
# flood_uuid=`/usr/bin/curl --silent --user ${FLOOD_API_TOKEN}: https://api.flood.io/floods \
# -F "region=ap-southeast-2" \
# -F "flood[tool]=jmeter" \
# -F "flood[threads]=${threads}" \
# -F "flood[rampup]=${rampup}" \
# -F "flood[duration]=${duration}" \
# -F "flood[name]=JMeter 2.9" \
# -F "flood[tag_list]=${tag}" \
# -F "flood[plan]=@${here}/benchmarks/spec/jmeter/benchmark.jmx" | /usr/local/bin/jq ".response.uuid" | tr -d '"'`
# poll_and_report

# Benchmark JMeter Latest
sudo latest=`/usr/bin/curl --silent http://ci.apache.org/projects/jmeter/nightlies/ | /bin/grep LATEST | /bin/egrep -o "r[0-9]+"`
sudo /usr/bin/wget -O /usr/share/jmeter-latest/jmeter_bin.zip http://ci.apache.org/projects/jmeter/nightlies/${latest}/apache-jmeter-${latest}_bin.zip
sudo /usr/bin/wget -O /usr/share/jmeter-latest/jmeter_lib.zip http://ci.apache.org/projects/jmeter/nightlies/${latest}/apache-jmeter-${latest}_lib.zip

sudo /usr/bin/unzip -u -o /usr/share/jmeter-latest/jmeter_bin.zip -d /usr/share/
sudo /usr/bin/unzip -u -o /usr/share/jmeter-latest/jmeter_lib.zip -d /usr/share/
sudo chown -R flood:flood /usr/share/apache-jmeter-${latest}

tool="JMeter-2.10"
flood_uuid=`/usr/bin/curl --silent --user ${FLOOD_API_TOKEN}: https://api.flood.io/floods \
-F "region=ap-southeast-2" \
-F "flood[tool]=apache-jmeter-${latest}" \
-F "flood[threads]=${threads}" \
-F "flood[rampup]=${rampup}" \
-F "flood[duration]=${duration}" \
-F "flood[name]=apache-jmeter-${latest}" \
-F "flood[tag_list]=${tag}-latest" \
-F "flood[plan]=@${here}/benchmarks/spec/jmeter/benchmark.jmx" | /usr/local/bin/jq ".response.uuid" | tr -d '"'`
poll_and_report

# Benchmark Gatling Nightly
# TODO
