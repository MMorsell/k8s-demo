#!/bin/bash

while true; do
    # Get the status of the pod
    pod_name=$(kubectl get pods --namespace metric-services -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=grafana" -o jsonpath="{.items[0].metadata.name}")
    status=$(kubectl get pod -n "metric-services" "$pod_name" -o jsonpath='{.status.phase}')

    # Check if the pod is in the 'Running' state
    if [ "$status" == "Running" ]; then
        echo "Grafana is running"
        break
    else
        echo "Grafana is not running yet, current status: $status"
        sleep 1 # Adjust the sleep duration as needed
    fi
done


grafana_ip=$(kubectl get service grafana -n metric-services -o=jsonpath='{.spec.clusterIP}')
echo $grafana_ip

name="test$RANDOM"

# Generate service account to import datasource and dashboards
genServiceRes=$(curl -X POST -H "Content-Type: application/json" -d "{\"name\":\"$name\", \"role\": \"Admin\"}" http://admin:password@$grafana_ip/api/serviceaccounts)
serviceId=$(echo "$genServiceRes" | jq -r '.id')
echo $serviceId

tokenRes=$(curl -X POST -H "Content-Type: application/json" -d "{\"name\":\"$name\", \"role\": \"Admin\"}" http://admin:password@$grafana_ip/api/serviceaccounts/$serviceId/tokens)
token=$(echo "$tokenRes" | jq -r '.key')
echo $token

dataSourceRes=$(curl -X POST --insecure -H "Authorization: Bearer $token" -H "Content-Type: application/json" -d '{
  "name":"prometheus",
  "type":"prometheus",
  "url":"http://prometheus-server:80",
  "access":"proxy",
  "basicAuth":false
}' http://$grafana_ip/api/datasources)
dbUID=$(echo "$dataSourceRes" | jq -r '.datasource.uid')
echo $dbUID


json_payload='{
  "dashboard": {
    "annotations": {
      "list": [
        {
          "builtIn": 1,
          "datasource": {
            "type": "grafana",
            "uid": "-- Grafana --"
          },
          "enable": true,
          "hide": true,
          "iconColor": "rgba(0, 211, 255, 1)",
          "name": "Annotations & Alerts",
          "type": "dashboard"
        }
      ]
    },
    "editable": true,
    "fiscalYearStartMonth": 0,
    "graphTooltip": 0,
    "links": [],
    "panels": [
      {
        "datasource": {
          "type": "prometheus",
          "uid": "<DBUID>"
        },
        "fieldConfig": {
          "defaults": {
            "color": {
              "mode": "palette-classic"
            },
            "custom": {
              "axisBorderShow": false,
              "axisCenteredZero": false,
              "axisColorMode": "text",
              "axisLabel": "",
              "axisPlacement": "auto",
              "barAlignment": 0,
              "drawStyle": "line",
              "fillOpacity": 0,
              "gradientMode": "none",
              "hideFrom": {
                "legend": false,
                "tooltip": false,
                "viz": false
              },
              "insertNulls": false,
              "lineInterpolation": "linear",
              "lineWidth": 1,
              "pointSize": 5,
              "scaleDistribution": {
                "type": "linear"
              },
              "showPoints": "auto",
              "spanNulls": false,
              "stacking": {
                "group": "A",
                "mode": "none"
              },
              "thresholdsStyle": {
                "mode": "off"
              }
            },
            "mappings": [],
            "thresholds": {
              "mode": "absolute",
              "steps": [
                {
                  "color": "green",
                  "value": null
                },
                {
                  "color": "red",
                  "value": 80
                }
              ]
            }
          },
          "overrides": []
        },
        "gridPos": {
          "h": 8,
          "w": 12,
          "x": 0,
          "y": 0
        },
        "id": 8,
        "options": {
          "legend": {
            "calcs": [],
            "displayMode": "list",
            "placement": "bottom",
            "showLegend": true
          },
          "tooltip": {
            "mode": "single",
            "sort": "none"
          }
        },
        "pluginVersion": "10.4.1",
        "targets": [
          {
            "datasource": {
              "type": "prometheus",
              "uid": "<DBUID>"
            },
            "disableTextWrap": false,
            "editorMode": "code",
            "expr": "sum(kube_pod_container_info{image=~\"telemetry-api.*\"}) by (image)",
            "fullMetaSearch": false,
            "includeNullMetadata": true,
            "instant": false,
            "legendFormat": "__auto",
            "range": true,
            "refId": "A",
            "useBackend": false
          }
        ],
        "title": "Number of pods runnning",
        "type": "timeseries"
      },
      {
        "datasource": {
          "type": "prometheus",
          "uid": "<DBUID>"
        },
        "fieldConfig": {
          "defaults": {
            "color": {
              "mode": "palette-classic"
            },
            "custom": {
              "axisBorderShow": false,
              "axisCenteredZero": false,
              "axisColorMode": "text",
              "axisLabel": "",
              "axisPlacement": "auto",
              "barAlignment": 0,
              "drawStyle": "line",
              "fillOpacity": 0,
              "gradientMode": "none",
              "hideFrom": {
                "legend": false,
                "tooltip": false,
                "viz": false
              },
              "insertNulls": false,
              "lineInterpolation": "linear",
              "lineWidth": 1,
              "pointSize": 5,
              "scaleDistribution": {
                "type": "linear"
              },
              "showPoints": "auto",
              "spanNulls": false,
              "stacking": {
                "group": "A",
                "mode": "none"
              },
              "thresholdsStyle": {
                "mode": "off"
              }
            },
            "mappings": [],
            "thresholds": {
              "mode": "absolute",
              "steps": [
                {
                  "color": "green",
                  "value": null
                },
                {
                  "color": "red",
                  "value": 80
                }
              ]
            }
          },
          "overrides": []
        },
        "gridPos": {
          "h": 8,
          "w": 12,
          "x": 12,
          "y": 0
        },
        "id": 5,
        "options": {
          "legend": {
            "calcs": [],
            "displayMode": "list",
            "placement": "bottom",
            "showLegend": true
          },
          "tooltip": {
            "mode": "single",
            "sort": "none"
          }
        },
        "targets": [
          {
            "datasource": {
              "type": "prometheus",
              "uid": "<DBUID>"
            },
            "editorMode": "code",
            "expr": "  rate(request_duration_seconds_sum[5m])\n/\n  rate(request_duration_seconds_count[5m])",
            "instant": false,
            "legendFormat": "status_code={{status_code}}, pod={{pod}}, node={{node}}",
            "range": true,
            "refId": "A"
          }
        ],
        "title": "Average request duration during the last 5 minutes",
        "type": "timeseries"
      },
      {
        "datasource": {
          "type": "prometheus",
          "uid": "<DBUID>"
        },
        "fieldConfig": {
          "defaults": {
            "color": {
              "mode": "palette-classic"
            },
            "custom": {
              "axisBorderShow": false,
              "axisCenteredZero": false,
              "axisColorMode": "text",
              "axisLabel": "",
              "axisPlacement": "auto",
              "barAlignment": 0,
              "drawStyle": "line",
              "fillOpacity": 0,
              "gradientMode": "none",
              "hideFrom": {
                "legend": false,
                "tooltip": false,
                "viz": false
              },
              "insertNulls": false,
              "lineInterpolation": "linear",
              "lineWidth": 1,
              "pointSize": 5,
              "scaleDistribution": {
                "type": "linear"
              },
              "showPoints": "auto",
              "spanNulls": false,
              "stacking": {
                "group": "A",
                "mode": "none"
              },
              "thresholdsStyle": {
                "mode": "off"
              }
            },
            "mappings": [],
            "thresholds": {
              "mode": "absolute",
              "steps": [
                {
                  "color": "green",
                  "value": null
                },
                {
                  "color": "red",
                  "value": 80
                }
              ]
            }
          },
          "overrides": []
        },
        "gridPos": {
          "h": 8,
          "w": 12,
          "x": 0,
          "y": 8
        },
        "id": 6,
        "options": {
          "legend": {
            "calcs": [],
            "displayMode": "list",
            "placement": "bottom",
            "showLegend": true
          },
          "tooltip": {
            "mode": "single",
            "sort": "none"
          }
        },
        "targets": [
          {
            "datasource": {
              "type": "prometheus",
              "uid": "<DBUID>"
            },
            "editorMode": "code",
            "expr": "sum(increase(request_duration_seconds_count[5m]))",
            "instant": false,
            "legendFormat": "__auto",
            "range": true,
            "refId": "A"
          }
        ],
        "title": "Reqests rate",
        "type": "timeseries"
      },
      {
        "datasource": {
          "type": "prometheus",
          "uid": "<DBUID>"
        },
        "fieldConfig": {
          "defaults": {
            "color": {
              "mode": "palette-classic"
            },
            "custom": {
              "axisBorderShow": false,
              "axisCenteredZero": false,
              "axisColorMode": "text",
              "axisLabel": "",
              "axisPlacement": "auto",
              "barAlignment": 0,
              "drawStyle": "line",
              "fillOpacity": 0,
              "gradientMode": "none",
              "hideFrom": {
                "legend": false,
                "tooltip": false,
                "viz": false
              },
              "insertNulls": false,
              "lineInterpolation": "linear",
              "lineWidth": 1,
              "pointSize": 5,
              "scaleDistribution": {
                "type": "linear"
              },
              "showPoints": "auto",
              "spanNulls": false,
              "stacking": {
                "group": "A",
                "mode": "none"
              },
              "thresholdsStyle": {
                "mode": "off"
              }
            },
            "mappings": [],
            "thresholds": {
              "mode": "absolute",
              "steps": [
                {
                  "color": "green",
                  "value": null
                },
                {
                  "color": "red",
                  "value": 80
                }
              ]
            }
          },
          "overrides": []
        },
        "gridPos": {
          "h": 8,
          "w": 12,
          "x": 12,
          "y": 8
        },
        "id": 9,
        "options": {
          "legend": {
            "calcs": [],
            "displayMode": "list",
            "placement": "bottom",
            "showLegend": true
          },
          "tooltip": {
            "mode": "single",
            "sort": "none"
          }
        },
        "targets": [
          {
            "datasource": {
              "type": "prometheus",
              "uid": "<DBUID>"
            },
            "editorMode": "code",
            "expr": "sum(increase(request_duration_seconds_count{status_code=\"200\"}[5m]))/sum(increase(request_duration_seconds_count[5m]))",
            "instant": false,
            "legendFormat": "Successful",
            "range": true,
            "refId": "A"
          },
          {
            "datasource": {
              "type": "prometheus",
              "uid": "<DBUID>"
            },
            "editorMode": "code",
            "expr": "sum(increase(request_duration_seconds_count{status_code=\"500\"}[5m]))/sum(increase(request_duration_seconds_count[5m]))",
            "hide": false,
            "instant": false,
            "legendFormat": "Errors",
            "range": true,
            "refId": "B"
          }
        ],
        "title": "Percentage result of POST (all versions)",
        "type": "timeseries"
      },
      {
        "datasource": {
          "type": "prometheus",
          "uid": "<DBUID>"
        },
        "fieldConfig": {
          "defaults": {
            "color": {
              "mode": "palette-classic"
            },
            "custom": {
              "axisBorderShow": false,
              "axisCenteredZero": false,
              "axisColorMode": "text",
              "axisLabel": "",
              "axisPlacement": "auto",
              "barAlignment": 0,
              "drawStyle": "line",
              "fillOpacity": 0,
              "gradientMode": "none",
              "hideFrom": {
                "legend": false,
                "tooltip": false,
                "viz": false
              },
              "insertNulls": false,
              "lineInterpolation": "linear",
              "lineWidth": 1,
              "pointSize": 5,
              "scaleDistribution": {
                "type": "linear"
              },
              "showPoints": "auto",
              "spanNulls": false,
              "stacking": {
                "group": "A",
                "mode": "none"
              },
              "thresholdsStyle": {
                "mode": "off"
              }
            },
            "mappings": [],
            "thresholds": {
              "mode": "absolute",
              "steps": [
                {
                  "color": "green",
                  "value": null
                },
                {
                  "color": "red",
                  "value": 80
                }
              ]
            }
          },
          "overrides": []
        },
        "gridPos": {
          "h": 8,
          "w": 12,
          "x": 0,
          "y": 16
        },
        "id": 7,
        "options": {
          "legend": {
            "calcs": [],
            "displayMode": "list",
            "placement": "bottom",
            "showLegend": true
          },
          "tooltip": {
            "mode": "single",
            "sort": "none"
          }
        },
        "targets": [
          {
            "datasource": {
              "type": "prometheus",
              "uid": "<DBUID>"
            },
            "editorMode": "code",
            "expr": "sum(increase(request_duration_seconds_count{status_code=\"200\"}[5m]))",
            "instant": false,
            "legendFormat": "Successful",
            "range": true,
            "refId": "A"
          },
          {
            "datasource": {
              "type": "prometheus",
              "uid": "<DBUID>"
            },
            "editorMode": "code",
            "expr": "sum(increase(request_duration_seconds_count{status_code=\"500\"}[5m]))",
            "hide": false,
            "instant": false,
            "legendFormat": "Errors",
            "range": true,
            "refId": "B"
          }
        ],
        "title": "Successful POST VS error POST",
        "type": "timeseries"
      }
    ],
    "refresh": "5s",
    "schemaVersion": 39,
    "tags": [],
    "templating": {
      "list": []
    },
    "time": {
      "from": "now-5m",
      "to": "now"
    },
    "timepicker": {},
    "timezone": "browser",
    "title": "telemetry",
    "uid": "fdjf7q2k3x62oc",
    "version": 2,
    "weekStart": ""
  },
  "folderUid": "",
  "overwrite": true
}'


json_payload="${json_payload//<DBUID>/$dbUID}"
curl -X POST --insecure -H "Authorization: Bearer $token" -H "Content-Type: application/json" -d "$json_payload" http://$grafana_ip/api/dashboards/db

echo "All done!"