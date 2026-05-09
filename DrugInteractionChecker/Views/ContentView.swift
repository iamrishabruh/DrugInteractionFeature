//
//  ContentView.swift
//  Drug Interaction Checker
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: DrugInteractionViewModel
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                Color(hex: "E9EBEE")

                VStack(alignment: .leading) {
                    HStack {
                        Text("Drug Interaction Checker")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(hex: "0C1C3C"))

                        NavigationLink(destination: InformationPage()) {
                            Text("ⓘ")
                                .fontWeight(.bold)
                        }
                    }
                    .padding(.top, 12)
                    .padding(.horizontal, 4)

                    Text(
                        "Add prescribed and over-the-counter medications to explore how a patient-facing app might surface multi-drug interaction context. This build uses mock data by default."
                    )
                    .font(.footnote)
                    .fontWeight(.light)
                    .foregroundColor(Color(red: 0.442, green: 0.467, blue: 0.535))
                    .multilineTextAlignment(.leading)
                    .padding(.vertical, 6)

                    ZStack(alignment: .center) {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .frame(height: 420)

                        VStack(alignment: .leading) {
                            Text("Medications")
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(Color(hex: "013B71"))
                                .padding(.horizontal, 8)

                            ScrollView {
                                VStack(spacing: 10) {
                                    ForEach(viewModel.medicationNames, id: \.self) { name in
                                        MedicationCard(name: name) {
                                            viewModel.removeMedication(named: name)
                                        }
                                    }
                                }
                                .padding(.horizontal, 8)
                            }
                            .frame(maxHeight: 260)

                            SearchBar(text: $searchText, onSearch: addMedication)
                        }
                        .padding(16)
                    }

                    NavigationLink {
                        InteractionReportView(viewModel: viewModel)
                    } label: {
                        Text("Check for interactions")
                            .font(.headline)
                            .foregroundColor(Color(hex: "0078B3"))
                            .multilineTextAlignment(.center)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 50)
                                    .stroke(Color(hex: "0078B3"))
                            )
                            .background(Color(hex: "F4FAFF"))
                            .cornerRadius(50)
                    }
                    .padding(.top, 20)
                    .disabled(viewModel.medicationNames.isEmpty)
                    .opacity(viewModel.medicationNames.isEmpty ? 0.45 : 1)

                    Spacer(minLength: 0)
                }
                .padding(16)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .tint(Color(hex: "0078B3"))
    }

    private func addMedication() {
        viewModel.addMedication(name: searchText)
        searchText = ""
    }
}

private struct MedicationCard: View {
    let name: String
    var onRemove: () -> Void

    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .foregroundColor(Color(hex: "F7F7F7"))
            .frame(height: 52)
            .overlay(
                HStack {
                    Image(systemName: "pill")
                        .font(.title2)
                        .foregroundColor(Color(hex: "013B71"))

                    Text(name)
                        .font(.callout)
                        .foregroundColor(Color(hex: "013B71"))
                        .lineLimit(2)

                    Spacer()

                    Button(action: onRemove) {
                        Image(systemName: "x.circle")
                            .font(.title3)
                            .foregroundColor(Color(hex: "0078B3"))
                    }
                }
                .padding(.horizontal, 12)
            )
    }
}

private struct SearchBar: View {
    @Binding var text: String
    var onSearch: () -> Void

    var body: some View {
        HStack {
            TextField("Add a medication", text: $text, onCommit: onSearch)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(8)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)

            Button(action: onSearch) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color(hex: "0078B3"))
            }
        }
        .padding(.top, 8)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: DrugInteractionViewModel(client: MockDrugInteractionClient()))
    }
}
