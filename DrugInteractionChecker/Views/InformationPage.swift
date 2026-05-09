//
//  InformationPage.swift
//  Drug Interaction Checker
//

import SwiftUI

struct InformationPage: View {
    var body: some View {
        ZStack(alignment: .center) {
            VStack(alignment: .center, spacing: 16) {
                Text("What are multidrug interactions?")
                    .font(.title)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Multidrug interactions happen when two or more medicines combine in ways that change effects, reduce benefit, or increase side effects.")
                        .foregroundColor(Color(hex: "013B71"))
                        .font(.subheadline)
                        .multilineTextAlignment(.leading)

                    Text("Understanding interactions helps patients and clinicians avoid preventable harm—but apps are not a substitute for professional judgment.")
                        .foregroundColor(Color(hex: "013B71"))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                Text(
                    "Multidrug interactions contribute to a measurable share of hospital admissions; risk rises as the number of medicines increases. This educational demo cites literature for context only."
                )
                .font(.headline)
                .fontWeight(.regular)
                .foregroundColor(Color(hex: "0078B3"))
                .multilineTextAlignment(.center)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color(hex: "0078B3"))
                )
                .background(Color(hex: "F4FAFF"))
                .cornerRadius(24)

                Spacer()

                Link(
                    "Reference: LWW journals article on clinical relevance of drug–drug interactions",
                    destination: URL(string: "https://journals.lww.com/picp/fulltext/2019/10020/are_drug_drug_interactions_a_real_clinical.4.aspx")!
                )
                .multilineTextAlignment(.center)
                .foregroundColor(Color(hex: "013B71"))
                .font(.caption)
            }
            .padding()
        }
    }
}

struct InformationPage_Previews: PreviewProvider {
    static var previews: some View {
        InformationPage()
    }
}
