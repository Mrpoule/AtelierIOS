//
//  ContentView.swift
//  AtelierIOS1
//
//  Created by Tech Info on 2024-04-15.
//

import SwiftUI
import OpenMeteoSdk




struct WeatherForecast {
    let current: Current
    let daily: Daily
}

struct Current  {
    let time : Date
    let temperature_2m : Float
    let weather_code : Float
}

struct Daily{
    let time : [Date]
    let weather_code : [Float]
    let temperature_2m_max: [Float]
    let temperature_2m_min: [Float]
}


struct ContentView: View {
    
    @State private var timeCurrent: Date = Date.now
    @State private var temperature2mCurrent: Float = 0
    @State private var weather_codeCurrent: Float = 0
    
    
    @State private var timeDaily: [Date] = []
    @State private var weather_codeDaily: [Float] = []
    @State private var temperature2mMaxDaily: [Float] = []
    @State private var temperture2mMinDaily: [Float] = []
    
    
    
    var body: some View {
        ZStack{
            Color.blue.ignoresSafeArea()
            VStack {
                Text("Saint-Georges de Beauce")
                Text("\(timeCurrent.formatted(date: Date.FormatStyle.DateStyle.abbreviated, time: Date.FormatStyle.TimeStyle.omitted))")
                Image(weatherCodeCalculateImage(weatherCode : weather_codeCurrent)).resizable().frame(width: 200, height: 200)
                Text("\(Int(temperature2mCurrent))C°")
                Text("A venir")
                HStack
                {
                    ForEach(0..<timeDaily.count,id: \.self) {index in
                        VStack{
                            Image(weatherCodeCalculateImage(weatherCode: weather_codeDaily[index])).resizable().frame(width: 100, height: 100)
                            Text("\(timeDaily[index].formatted(date: Date.FormatStyle.DateStyle.abbreviated, time: Date.FormatStyle.TimeStyle.omitted))")
                                Text("Max: \(Int(temperture2mMinDaily[index]))C°")
                                Text("Min: \(Int(temperature2mMaxDaily[index]))C°")
                            
                        }
                    }
                }
            }
        }
        .padding()
        .onAppear{fecthApi()}
    }
    func fecthApi(){
        async{
            let url = URL(string:"https://api.open-meteo.com/v1/forecast?latitude=46.1264&longitude=-70.6698&current=temperature_2m,weather_code&daily=weather_code,temperature_2m_max,temperature_2m_min&timezone=America%2FNew_York&forecast_days=3&format=flatbuffers")!
            let responses = try await WeatherApiResponse.fetch(url:url)
            let response = responses[0]
            
            let utcOffsetSeconds = response.utcOffsetSeconds
            
            
            let current = response.current!
            let daily = response.daily!
            
            let data = WeatherForecast(
               current: .init (
                   time: Date(timeIntervalSince1970: TimeInterval(current.time + Int64(utcOffsetSeconds))),
                   temperature_2m: current.variables(at: 0)!.value,
                   weather_code: current.variables(at: 1)!.value
               ),
               daily: .init(
                   time: daily.getDateTime(offset: utcOffsetSeconds),
                   weather_code: daily.variables(at: 0)!.values,
                   temperature_2m_max: daily.variables(at: 1)!.values,
                   temperature_2m_min: daily.variables(at: 2)!.values
               )
            )
            
            timeCurrent = data.current.time
            temperature2mCurrent = data.current.temperature_2m
            weather_codeCurrent = data.current.weather_code
            
            
            
            for (i,date) in data.daily.time.enumerated()
            {
                timeDaily.append(data.daily.time[i])
                weather_codeDaily.append(data.daily.weather_code[i])
                temperature2mMaxDaily.append(data.daily.temperature_2m_max[i])
                temperture2mMinDaily.append(data.daily.temperature_2m_min[i])
            }
    
            
            
            
        }
   }
}
func weatherCodeCalculateImage (weatherCode: Float)-> String
{
    switch weatherCode {
    case 0..<20 :
        return "sunny"
    case 20..<30 :
        return "rainy"
    case 30..<40 :
        return "snowy"
    case 40..<50 :
        return "cloudy"
    default:
        return "defaultImage"
    }
}
struct dailyView: View
{
    @State private var time: String
    @State private var imageName: String
    @State private var TempMax: String
    @State private var TempMin: String
    var body: some View
    {
        VStack
        {
            Image(imageName)
            Text(time)
            Text(TempMax)
            Text(TempMin)
        }
    }

}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

