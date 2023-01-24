import SwiftUI

struct ListOfCitiesView: View {
  @Binding var selectedCity : String
  @Binding var showCityList : Bool
  let cityNames = ["Toronto", "Montreal", "Ottawa", "Vancouver", "Calgary"]

  var body: some View {
    ZStack {
      SkyImageView()
      VStack(alignment: .center) {
        HStack{
          Spacer()
          Button(action: {
            showCityList.toggle()
          }){
            Image(systemName: "xmark")
              .foregroundColor(.white)
          }
        }
        .padding(.all)
        Text(selectedCity)
          .foregroundColor(.white)
          .font(.title)
          .fontWeight(.bold)
        //city list
        ForEach(cityNames,id:\.self) {city in
          HStack{
            Image(systemName: "building")
            Text(city)
              .fontWeight(.bold)
            Spacer()
          }
          .foregroundColor(.white)
          .padding(.all)
          .onTapGesture {
            DispatchQueue.main.async {
              selectedCity = city
              showCityList.toggle()
            }
          }
          Divider()
            .foregroundColor(.white)
        }
        Spacer()
      }
    }
  }
}

struct ListOfCitiesView_Previews: PreviewProvider {
  static var previews: some View {
    ListOfCitiesView(selectedCity: .constant("Toronto"),
                     showCityList: .constant(false))
  }
}
