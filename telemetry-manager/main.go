package main

import (
	"github.com/gin-gonic/gin"
	"net/http"
        "github.com/influxdata/influxdb-client-go/v2"
	//"github.com/influxdata/influxdb-client-go/v2/api/query"
        "context"
        "fmt"
        "time"
)


const (
	//influxURL      = "http://192.168.1.107:32701"
	influxURL      = "http://10.165.242.55:32701"
	influxToken    = "X6zYQsXQdkC4K-WE7Uza_Z7yYWkENe3PAbNPIjryr4_KECA75QoLqALgsX9XQjWMFhdhZFz1TiLjxYUiM7B1zw=="
	influxOrg      = "intel"
	influxBucket   = "intel"
)

type Query struct {
        UserId string  `json:"id"`
	Token  string  `json:"token"`
	Group  string  `json:"group"`
	Test  string   `json:"test"`

}

type DataResult struct {
        Measurement string  `json:"measurement"`
	Value  float64  `json:"value"`
	StartTsp  time.Time  `json:"start"`
	StopTsp  time.Time  `json:"stop"`
        Host string  `json:"host"`
        Group string  `json:"group"`
        UserId string  `json:"userid"`
}


func retrieveData (qryObj Query, flag int)[]DataResult {

        var dataItx DataResult
        var dataResult []DataResult
        var fluxQuery string 


        metrices  := qryObj.Test  //TODO: this is just temp, user should pass in group identifier, and the identifier will link to set of measurement and host
        fmt.Println(metrices)


        client := influxdb2.NewClient(influxURL, influxToken)
	defer client.Close()

        // Create a Flux query, TODO: need to modularized influx syntax

        if flag == 1 {
		fluxQuery = fmt.Sprintf(`from(bucket: "%s")
			|> range(start: -1h)
			|> filter(fn: (r) => r._measurement == "%s")`, influxBucket,metrices)
        } else {

		fluxQuery = fmt.Sprintf(`from(bucket: "%s")
			|> range(start: -24h)
                        |> filter(fn: (r) =>r._measurement == "cpu_usage_idle" and r.cpu== "cpu-total")
                        |> limit(n: 10)`, influxBucket)

       }



        // Execute the query
	queryAPI := client.QueryAPI(influxOrg)
	result, err := queryAPI.Query(context.Background(), fluxQuery)
	if err != nil {
		fmt.Printf("Error executing query:", err)
		return dataResult
	}
	defer result.Close()


        for result.Next() {
		if result.TableChanged() {
			// New table started, print the table name
			fmt.Printf("Table: %s\n", result.TableMetadata().String())
		}

	        record := result.Record()
		//val := record.ValueByKey("_value").(float64)

                dataItx.Measurement = record.ValueByKey("_measurement").(string)
		dataItx.Value = record.ValueByKey("_value").(float64)
		dataItx.StartTsp = record.ValueByKey("_start").(time.Time)
		dataItx.StopTsp = record.ValueByKey("_stop").(time.Time)
		dataItx.Host = record.ValueByKey("host").(string)
		dataItx.UserId = qryObj.UserId
		dataItx.Group = qryObj.Group


                dataResult = append (dataResult,dataItx)

	}

        return dataResult

}

func getMetrices(c *gin.Context) {


        var qry Query
        var dataResult []DataResult

        if err := c.BindJSON(&qry); err != nil {
                fmt.Println("Incorrect Query!")
		return
	}

        fmt.Println(qry.UserId)
        fmt.Println(qry.Token)
        fmt.Println(qry.Group)

        dataResult = retrieveData (qry,1)
	c.IndentedJSON(http.StatusOK, dataResult)
}

func getDefault()[]DataResult{


        var qry Query
        var dataResult []DataResult
        qry.Group = "Sample"
        qry.Test = "cpu_usage_idle"

        dataResult = retrieveData (qry,0)
        return dataResult
	//c.IndentedJSON(http.StatusNotFound, dataResult)
}

func main() {
	router := gin.Default()
	router.GET("/telemetry", getMetrices)

        defaultMsg := "Requested Telemetry Path not found. You could query API, for example:\n" +
                      "curl -k https://telemetry.yockgen.api:31244/telemetry \n" +
                      "--include --header \"Content-Type: application/json\" \n" +
                      "--request \"GET\" \n" +
                      "--data '{\"id\": \"yockgenm\",\"Token\": \"32434ewew4434344df==\",\"Group\": \"ADMIN01\", \"TEST\":\"mem_used_percent\"}'"

        // Handle 404 - Path not found
	router.NoRoute(func(c *gin.Context) {
		c.JSON(http.StatusNotFound, gin.H{"message": defaultMsg,"sample": getDefault()})
	})

       //router.NoRoute(getDefault())

       router.Run("0.0.0.0:8080")
}
