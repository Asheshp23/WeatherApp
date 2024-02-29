import SwiftUI

struct ListOfCitiesView: View {
  @Binding var selectedCity : String
  @Binding var showCityList : Bool
  
  let cityNames = ["London", "Paris", "New York City", "Tokyo", "Rome", "Sydney", "Bangkok", "Istanbul", "Dubai", "Hong Kong", "Barcelona", "Madrid", "Moscow", "Beijing", "Los Angeles", "Chicago", "Shanghai", "Toronto", "Singapore", "Berlin"]

  var body: some View {
    VStack(alignment: .center) {
      List {
        ForEach(cityNames,id:\.self) { city in
          Button(action: {
            Task { @MainActor in
              if selectedCity != city {
                selectedCity = city
                showCityList.toggle()
              }
            }
          }, label: {
            HStack {
              Image(systemName: "building")
              Text(city)
              Spacer()
            }
            .font(.title3.bold())
            .foregroundStyle(
                .linearGradient(
                    colors: [.gray, .black],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
          })
        }
      }
      .background(Image("SKY"))
    }
  }
}

struct ListOfCitiesView_Previews: PreviewProvider {
  static var previews: some View {
    ListOfCitiesView(selectedCity: .constant("Toronto"),
                     showCityList: .constant(false))
  }
}
