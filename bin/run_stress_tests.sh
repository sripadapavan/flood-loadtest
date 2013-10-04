#!/bin/bash
FLOOD_API_TOKEN=$1

here="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../" && pwd )"

echo ${FLOOD_API_TOKEN}
echo ${here}
echo --

function poll_and_report {
  echo Detailed results at https://flood.io/${flood_uuid}
  flood_status="queued"
  while [ "${flood_status}" != "finished" ]; do
    echo Polling ${flood_uuid} current status ${flood_status} ...
    flood_status=`/usr/bin/curl --silent --user ${FLOOD_API_TOKEN}: https://api.flood.io/floods/${flood_uuid} | /usr/local/bin/jq ".response.status" | tr -d '"'`
    sleep 3
  done

  flood_report=`/usr/bin/curl --silent --user ${FLOOD_API_TOKEN}: https://api.flood.io/floods/${flood_uuid}/report | /usr/local/bin/jq ".response.report" | tr -d '"'`
  apdex=`/usr/bin/curl --silent --user ${FLOOD_API_TOKEN}: https://api.flood.io/floods/${flood_uuid} | /usr/local/bin/jq ".response.apdex" | tr -d '"'`
  mean_response_time=`/usr/bin/curl --silent --user ${FLOOD_API_TOKEN}: https://api.flood.io/floods/${flood_uuid} | /usr/local/bin/jq ".response.mean_response_time" | tr -d '"'`

  echo >> ${here}/benchmarks/results/${flood_uuid}.md
  echo "### ${version} ${threads} Users" >> ${here}/benchmarks/results/${flood_uuid}.md
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

  echo "| [:chart_with_upwards_trend:](./benchmarks/results/${flood_uuid}.md) [:link:](https://flood.io/${flood_uuid}) ${version} | $((duration/60)) mins<br>`date +"%F %T"` | ${threads} | ${apdex} | ${mean_response_time} |" >> ${here}/README.md

  cd ~/flood-loadtest
  git add .
  git commit -am "Updating benchmarks from `date`"
  git push

  echo | sudo tee /var/log/flood/verbosegc.log
}

echo | sudo tee /var/log/flood/verbosegc.log

threads=20000
rampup=300
duration=1200

tag=stress

# Benchmark Gatling Current 1.5.3
tool="Gatling-1.5.3"
flood_uuid=`/usr/bin/curl --silent --user ${FLOOD_API_TOKEN}: https://api.flood.io/floods \
-F "region=ap-southeast-2" \
-F "flood[tool]=gatling" \
-F "flood[threads]=${threads}" \
-F "flood[rampup]=${rampup}" \
-F "flood[duration]=$((duration-rampup))" \
-F "flood[name]=Gatling 1.5.3" \
-F "flood[tag_list]=${tag}" \
-F "flood[plan]=@${here}/benchmarks/spec/gatling/1.5.3/stress.scala" | /usr/local/bin/jq ".response.uuid" | tr -d '"'`
poll_and_report

# Benchmark JMeter Current 2.9
tool="JMeter-2.9"
flood_uuid=`/usr/bin/curl --silent --user ${FLOOD_API_TOKEN}: https://api.flood.io/floods \
-F "region=ap-southeast-2" \
-F "flood[tool]=jmeter" \
-F "flood[threads]=${threads}" \
-F "flood[rampup]=${rampup}" \
-F "flood[duration]=${duration}" \
-F "flood[name]=JMeter 2.9" \
-F "flood[tag_list]=${tag}" \
-F "flood[plan]=@${here}/benchmarks/spec/jmeter/stress.jmx" | /usr/local/bin/jq ".response.uuid" | tr -d '"'`
poll_and_report

# Benchmark JMeter Latest
latest=`/usr/bin/curl --silent http://ci.apache.org/projects/jmeter/nightlies/ | /bin/grep LATEST | /bin/egrep -o "r[0-9]+"`
sudo /usr/bin/wget -O /usr/share/jmeter-latest/jmeter_bin.zip http://ci.apache.org/projects/jmeter/nightlies/${latest}/apache-jmeter-${latest}_bin.zip
sudo /usr/bin/wget -O /usr/share/jmeter-latest/jmeter_lib.zip http://ci.apache.org/projects/jmeter/nightlies/${latest}/apache-jmeter-${latest}_lib.zip

sudo /usr/bin/unzip -u -o /usr/share/jmeter-latest/jmeter_bin.zip -d /usr/share/
sudo /usr/bin/unzip -u -o /usr/share/jmeter-latest/jmeter_lib.zip -d /usr/share/
sudo /bin/mv -f /usr/share/apache-jmeter* /usr/share/jmeter-${latest}
sudo /bin/chown -R flood:flood /usr/share/jmeter-${latest}

version="JMeter-${latest}"
flood_uuid=`/usr/bin/curl --silent --user ${FLOOD_API_TOKEN}: https://api.flood.io/floods \
-F "region=ap-southeast-2" \
-F "flood[tool]=jmeter-${latest}" \
-F "flood[threads]=${threads}" \
-F "flood[rampup]=${rampup}" \
-F "flood[duration]=${duration}" \
-F "flood[name]=JMeter-${latest}" \
-F "flood[tag_list]=${tag}-latest, ${latest}" \
-F "flood[plan]=@${here}/benchmarks/spec/jmeter/stress.jmx" | /usr/local/bin/jq ".response.uuid" | tr -d '"'`
poll_and_report

# Benchmark Gatling Latest
latest=`/usr/bin/curl --silent http://repository-gatling.forge.cloudbees.com/snapshot/io/gatling/highcharts/gatling-charts-highcharts/2.0.0-SNAPSHOT/ | /bin/egrep -o "gatling-charts.+bundle.zip" | /usr/bin/head -n1 | /usr/bin/cut -d">" -f2 | /bin/egrep -o "2.+bundle"`
sudo /usr/bin/wget -O /usr/share/gatling-latest/gatling.zip http://repository-gatling.forge.cloudbees.com/snapshot/io/gatling/highcharts/gatling-charts-highcharts/2.0.0-SNAPSHOT/gatling-charts-highcharts-${latest}.zip

sudo /usr/bin/unzip -u -o /usr/share/gatling-latest/gatling.zip -d /usr/share/
sudo /bin/mv -f /usr/share/gatling-charts-highcharts* /usr/share/gatling-${latest}
sudo /bin/chown -R flood:flood /usr/share/gatling-${latest}

version="Gatling-${latest}"
flood_uuid=`/usr/bin/curl --silent --user ${FLOOD_API_TOKEN}: https://api.flood.io/floods \
-F "region=ap-southeast-2" \
-F "flood[tool]=gatling-${latest}" \
-F "flood[threads]=${threads}" \
-F "flood[rampup]=${rampup}" \
-F "flood[duration]=$((duration-rampup))" \
-F "flood[name]=Gatling-${latest}" \
-F "flood[tag_list]=${tag}-latest, ${latest}" \
-F "flood[plan]=@${here}/benchmarks/spec/gatling/2.0.0/stress.scala" | /usr/local/bin/jq ".response.uuid" | tr -d '"'`
poll_and_report

