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
