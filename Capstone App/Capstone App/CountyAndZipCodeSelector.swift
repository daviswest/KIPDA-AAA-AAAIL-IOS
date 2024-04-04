import SwiftUI

struct CountyAndZipCodeSelector: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedCounties: Set<String>
    @Binding var selectedZipCodes: Set<String>
    let countiesWithZipCodes: [String: [String]]

    // Tracks which county's zip codes are currently shown in the dropdown
    @State private var expandedCounty: String? = nil

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Select County")) {
                    ForEach(countiesWithZipCodes.keys.sorted(), id: \.self) { county in
                        HStack {
                            Text(county)
                            Spacer()
                            
                            // Show "Deselect All" and dropdown only if the county is selected
                            if selectedCounties.contains(county) {
                                        // The button text dynamically changes based on whether all zip codes in the county are selected.
                                        Button(action: {
                                            toggleSelectAllForCounty(county, withZipCodes: countiesWithZipCodes[county] ?? [])
                                        }) {
                                            // Check the selection status of zip codes for the "Select All" or "Deselect All" label.
                                            Text(isAllZipCodesSelected(in: county) ? "Deselect All Zip Codes" : "")
                                                .foregroundColor(.blue)
                                        }
                                        
                                        // Dropdown Toggle
                                        Button(action: {
                                            withAnimation {
                                                expandedCounty = expandedCounty == county ? nil : county
                                            }
                                        }) {
                                            Image(systemName: "chevron.down")
                                                .rotationEffect(.degrees(expandedCounty == county ? 180 : 0))
                                                .foregroundColor(.blue)
                                        }
                                        .buttonStyle(BorderlessButtonStyle())
                                    }                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            toggleCountySelection(county)
                        }

                        // Conditionally display zip codes for the expanded county
                        if expandedCounty == county, let zipCodes = countiesWithZipCodes[county], selectedCounties.contains(county) {
                            ForEach(zipCodes, id: \.self) { zipCode in
                                Button(action: {
                                    if selectedZipCodes.contains(zipCode) {
                                        selectedZipCodes.remove(zipCode)
                                    } else {
                                        selectedZipCodes.insert(zipCode)
                                    }
                                }) {
                                    HStack {
                                        Text(zipCode)
                                        Spacer()
                                        if selectedZipCodes.contains(zipCode) {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.blue)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("Select Recipients", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }

    private func toggleCountySelection(_ county: String) {
        if selectedCounties.contains(county) {
            selectedCounties.remove(county)
            expandedCounty = nil // Collapse the dropdown when a county is deselected
            // Optionally remove all selected zip codes for this county
            countiesWithZipCodes[county]?.forEach { selectedZipCodes.remove($0) }
        } else {
            selectedCounties.insert(county)
            // Optionally select all zip codes for this county by default when it's selected
            countiesWithZipCodes[county]?.forEach { selectedZipCodes.insert($0) }
        }
    }

    private func isAllZipCodesSelected(in county: String) -> Bool {
        guard let zipCodes = countiesWithZipCodes[county] else { return false }
        return Set(zipCodes).isSubset(of: selectedZipCodes)
    }

    private func toggleSelectAllForCounty(_ county: String, withZipCodes zipCodes: [String]) {
        let zipCodeSet = Set(zipCodes)
        if isAllZipCodesSelected(in: county) {
            zipCodeSet.forEach { selectedZipCodes.remove($0) }
        } else {
            selectedZipCodes.formUnion(zipCodeSet)
        }
    }
}
