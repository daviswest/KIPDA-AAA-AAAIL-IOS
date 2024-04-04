import SwiftUI

struct CountySelector: View {
    @Binding var selectedCounties: Set<String>
    let counties: [String]
    
    var body: some View {
        List(counties, id: \.self) { county in
            HStack {
                Text(county)
                Spacer()
                if selectedCounties.contains(county) {
                    Image(systemName: "checkmark")
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                if selectedCounties.contains(county) {
                    selectedCounties.remove(county)
                } else {
                    selectedCounties.insert(county)
                }
            }
        }
    }
}
