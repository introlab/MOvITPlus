# Formatted JSON data to transmit
A JSON object will be transmitted periodically throughout the day at every hour provided there is an internet connection and the file has not already been sent. The software will make sure to only send completed day, this means the most up to date data will be the one of yesterday. There may be one or more files transmitted if there was no network connection for a while. Each file will contain all the data of a single day.

## File naming convention
Each transmitted file will contain the user Id, the chair Id, and the date in regular DD-MM-YY format, in that order. Provided the user Id `P10MXJ`, the chair Id `EF7413` and the date March 5, 2019, the file name will then be `MOVIT+ P10MXJ_EF7413_05-03-19.json`. It will then be easy to filter the data by a specific user.

## JSON formatting
The following section details the different fields in the transmitted JSON object. You can find an example at the end of this document. Each key in the object follows the camel case naming convention.

### Object root node
The root of the object contains all the required data to recreate the graphics and store the data in a database. Here is the description of each top level field:
| Key        | Description           | Unit  | Datatype  | Range |
| :------------- |:-------------| :-----:| :-----:| :-----:|
|createdAt|Timestamp of the creation of the file in the same timezone as the sensors|ms|long|0 to today's Date|
|userId|The user Id provided by TelAsk||||
|maxAngle|The maximum angle of tilt the wheel chair can acheive|degree|Integer|-360° to 360°|
|minAngle|The minimum angle of tilt the wheel chair can acheive|degree|Integer|-360° to 360°|
|weight|The weight of the patient|Kg|Integer|greater or equal to 0|
|chairId|The unique identifier of the chair||String||
|dayStart|The timestamp of the begining of the day at 00h00|ms|Long|greater or equal to 0|
|dayEnd|The timestamp of the end of the day at 23h59|ms|Long|greater or equal to 0|
|timezone|The timezone of the device|hours|Integer|-11 to 12|
|rev|The revision of the JSON file format for verification purpose and future additions||String||
|tilt|The tilt data for the day, described below||Object||
|pressure|The pressure data for the day, described below||Object||

### tilt node
This object contains all the tilt data for a specified day. It is separated in multiple objects each containing data related to a single chart. Here is a description of each field:
| Key        | Description           | Unit  | Datatype  | Range |
| :-------------|:-------------|:-----:|:-----:| :-----:|
|distribution|Contains data related to the distribution of angle, used to create a pie chart. The data is contained in data, and the explanation of each element of data is in the index||Object||
|distribution.index|Explanation of each value of the data array sorted by index. The length of the array is 5 || String array ||
|distribution.data|The actual data representing the time spent in each of the five categories of the index | ms | Integer array | greater or equal to 0 |
|tiltMade|Contains data related to the number of tilt done in a day. The data is contained in data, and the explanation of each element in the index ||||
|tiltMade.index|Explanation of each value of the data array sorted by index. The length of the array is 5||Integer Array||
|tiltMade.data|Contains data related to the number of tilt done in a day. The data is contained in data, and the explanation of each element in the index | Number of tilt  | Integer array |greater or equal to 0|
|slidingTravelGoal|The sliding while travelling completion goal | % | Float | 0.0 to 1.0|
|slidingRestGoal|The sliding while at rest completion goal | % | Float  | 0.0 to 1.0|

### pressure node
This object contains all the pressure data for a specified day. It is separated in multiple objects each containing data related to a single chart. Here is the description of each field:
| Key        | Description           | Unit  | Datatype  | Range |
| :------------- |:-------------| :-----:| :-----:| :-----:|
|relievePressureGoal|The percentage of completion of the relieve pressure goal set by the clinician| % | Float | 0.0 to 1.0|
|relievePressurePersonalGoal|The percentage of completion of the relieve pressure goal set by the patient| % | Float  | 0.0 to 1.0|
|byTimestamp|Contains an object used as a dictionnary sorted by timestamp in ms. Each timestamp contains a pressureData object explained later. The pressure data can be taken at a maximum of 1 Hz. Each of these objects will need to be shown in a chart||Object||

#### pressureData Object
The pressureData object contains all the pressure information at a specific time. This data represents the overall center of gravity as well as the per quadrant center of gravity. Here is the description of each field:
| Key        | Description           | Unit  | Datatype  | Range |
| :------------- |:-------------| :-----:| :-----:| :-----:|
|center|The center of pression of the patient in x and y coordinate|In|Float|-4.0 to 4.0|
|quadrants|The center of pression of the patient per quadrant starting at the top left quadrant then clockwise in x and y coordinate|In|Float|-4.0 to 4.0|



# Example JSON
``` json
{
  "createdAt": 0,
  "userId": "",
  "maxAngle": 0,
  "weight": 0,
  "chairId": "",
  "dayStart": 0,
  "dayEnd": 0,
  "timezone": 0,
  "minAngle": 0,
  "rev": "A",
  "tilt": {
    "distribution": {
      "index": [
        "Less than 0°",
        "0° to 15°",
        "0° to 30°",
        "30° to 45°",
        "More than 45°"
      ],
      "data": [
        0,
        0,
        0,
        0,
        0
      ]
    },
    "tiltMade": {
      "index": [
        "Good angle and duration",
        "Good angle but insufficient duration",
        "Wrong angle but good duration",
        "Cancelled tilt",
        "Snoozed tilt"
      ],
      "data": [
        0,
        0,
        0,
        0,
        0
      ]
    },
    "slidingTravelGoal": 0,
    "slidingRestGoal": 0
  },
  "pressure": {
    "relievePressureGoal": 0,
    "relievePressurePersonalGoal": 0,
    "byTimestamp": {
      "1543412675000": {
        "center": {
          "x": 0,
          "y": 0
        },
        "quadrants": [
          {
            "x": 0,
            "y": 0
          },
          {
            "x": 0,
            "y": 0
          },
          {
            "x": 0,
            "y": 0
          },
          {
            "x": 0,
            "y": 0
          }
        ]
      }
    }
  }
}
```