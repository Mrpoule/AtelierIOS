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
            Color.blue.edgesIgnoringSafeArea(.all)
            VStack {
            Image(systemName: "globe")
                .imageScale(.large)
            Text("\(timeCurrent)")
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


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
