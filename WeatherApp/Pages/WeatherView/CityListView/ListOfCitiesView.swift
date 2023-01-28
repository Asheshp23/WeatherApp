import SwiftUI

struct ListOfCitiesView: View {
  @Binding var selectedCity : String
  @Binding var showCityList : Bool
  let cityNames = ["London", "Paris", "New York City", "Tokyo", "Rome", "Sydney", "Bangkok", "Istanbul", "Dubai", "Hong Kong", "Barcelona", "Madrid", "Moscow", "Beijing", "Los Angeles", "Chicago", "Shanghai", "Toronto", "Singapore", "Berlin"]

  var body: some View {
    VStack(alignment: .center) {
      //city list
      List {
        ForEach(cityNames,id:\.self) { city in
          HStack{
            Image(systemName: "building")
              .font(.headline)
            Text(city)
              .fontWeight(.bold)
            Spacer()
          }
          .padding(.all)
          .onTapGesture {
            DispatchQueue.main.async {
              selectedCity = city
              showCityList.toggle()
            }
          }
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
