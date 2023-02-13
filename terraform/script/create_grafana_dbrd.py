from grafana_api.grafana_face import GrafanaFace

grafana_api = GrafanaFace(
          auth='eyJrIjoic2kxWDVmeFl4bW1PTkpNMHM4NHBtNHo1cGY1eGprS3oiLCJuIjoidGVzdDAxIiwiaWQiOjF9',
          host='192.168.1.107:3000'
          )



_dbrd = grafana_api.search.search_dashboards(tag='test02')
print (len(_dbrd))
if len(_dbrd)>0:
    _itx = _dbrd[0]
    grafana_api.dashboard.delete_dashboard(dashboard_uid=_itx["uid"])


pnl_01 = {'title':'Memory Usage on Node 1'}
pnl_01["type"]="timeseries"
pnl_01["datasource"]={'type':'influxdb','uid':'vbf3Km14z'}
pnl_01_qry = {'refId':'A'}
pnl_01_qry["datasource"]={'type':'influxdb','uid':'vbf3Km14z'}
pnl_01_qry["query"] = "from(bucket: \"intel\")\r\n  |> range(start: -60m)\r\n  |> filter(fn: (r) =>\r\n    r._measurement == \"mem_used\" and r.host == \"192.168.1.107\"\r\n  )"
pnl_01["targets"] = [pnl_01_qry]
pnl_01["gridPos"] = {'h':8,'w':12,'x':0,'y':0}


pnl_02 = {'title':'Memory Usage on Node 2'}
pnl_02["type"]="timeseries"
pnl_02["datasource"]={'type':'influxdb','uid':'vbf3Km14z'}
pnl_02_qry = {'refId':'A'}
pnl_02_qry["datasource"]={'type':'influxdb','uid':'vbf3Km14z'}
pnl_02_qry["query"] = "from(bucket: \"intel\")\r\n  |> range(start: -60m)\r\n  |> filter(fn: (r) =>\r\n    r._measurement == \"mem_used\" and r.host == \"192.168.1.111\"\r\n  )"
pnl_02["targets"] = [pnl_02_qry]
pnl_02["gridPos"] = {'h':8,'w':12,'x':14,'y':0}

pnl_config = [pnl_01, pnl_02]
grafana_api.dashboard.update_dashboard(dashboard={'dashboard': {'tags':['test02'], 'title': 'Test Intel 02','type':'dash-db','panels':pnl_config}, 'folderId': 0, 'overwrite': True})

