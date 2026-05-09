//
//  InteractionReportView.swift
//  Drug Interaction Checker
//

import SwiftUI

struct InteractionReportView: View {
    @ObservedObject var viewModel: DrugInteractionViewModel

    var body: some View {
        ZStack {
            Color(hex: "E9EBEE")

            VStack(alignment: .leading, spacing: 12) {
                Text("Interaction report")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(hex: "0C1C3C"))
                    .padding(.top, 24)

                Text("This screen summarizes modeled or live interaction rows for the medications you entered. It is for learning and prototyping only.")
                    .font(.footnote)
                    .fontWeight(.light)
                    .foregroundColor(Color(red: 0.442, green: 0.467, blue: 0.535))
                    .fixedSize(horizontal: false, vertical: true)

                Group {
                    switch viewModel.phase {
                    case .idle:
                        Text("Tap refresh to load interactions.")
                            .foregroundColor(.secondary)
                    case .loading:
                        ProgressView("Checking interactions…")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 40)
                    case .loaded(let rows):
                        if rows.isEmpty {
                            NoInteractionsFoundView()
                        } else {
                            ScrollView {
                                VStack(spacing: 12) {
                                    ForEach(rows) { row in
                                        InteractionReportCard(interaction: row)
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                        }
                    case .failed(let error):
                        ErrorCallout(message: error.localizedDescription) {
                            viewModel.acknowledgeError()
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

                Text("Educational proof of concept only. Not medical advice. Always consult a qualified clinician or pharmacist about your medications.")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 8)
            }
            .padding(.horizontal, 16)
        }
        .edgesIgnoringSafeArea(.bottom)
        .navigationTitle("Interaction report")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadInteractions()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Refresh") {
                    Task { await viewModel.loadInteractions() }
                }
            }
        }
    }
}

struct NoInteractionsFoundView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("No interaction rows returned")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)

            Text("That may mean no modeled interactions were found for this set, or names did not match drug directory entries. Double-check spelling and try common generic names.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.35))
        )
        .padding(.vertical, 24)
    }
}

struct ErrorCallout: View {
    let message: String
    var onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Something went wrong")
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Button("Dismiss", action: onDismiss)
                .buttonStyle(.bordered)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
    }
}

struct InteractionReportCard: View {
    let interaction: DrugInteraction

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(interaction.severity.displayLabel) risk")
                    .font(.title3)
                    .fontWeight(.semibold)
                Spacer()
                Circle()
                    .fill(Color(hex: interaction.severity.indicatorHex))
                    .frame(width: 22, height: 22)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(formatDrugName(interaction.drug1Name))
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(hex: "0078B3"))
                Text(formatDrugName(interaction.drug2Name))
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(hex: "0078B3"))
            }

            Text(interaction.clinicalDescription)
                .font(.subheadline)
                .fontWeight(.light)
                .foregroundColor(Color(hex: "7F8596"))
                .fixedSize(horizontal: false, vertical: true)

            Text(interaction.recommendation)
                .font(.footnote)
                .foregroundColor(Color(hex: "013B71"))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(15)
        .background(Color.white)
        .cornerRadius(15)
    }
}

private func formatDrugName(_ input: String) -> String {
    let lowercasedInput = input.lowercased()
    let firstLetter = lowercasedInput.prefix(1).capitalized
    let restOfString = lowercasedInput.dropFirst()
    return firstLetter + restOfString
}

private extension InteractionSeverity {
    var displayLabel: String {
        switch self {
        case .unknown: return "Unknown"
        default: return rawValue.prefix(1).uppercased() + rawValue.dropFirst()
        }
    }

    var indicatorHex: String {
        switch self {
        case .high: return "EF2828"
        case .moderate: return "EFAB28"
        case .low: return "EED602"
        case .unknown: return "9DC9DF"
        }
    }
}

struct InteractionReportView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            InteractionReportView(viewModel: DrugInteractionViewModel(client: MockDrugInteractionClient()))
        }
    }
}
