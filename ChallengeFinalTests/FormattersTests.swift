//
//  FormattersTests.swift
//  ChallengeFinal
//
//  Created by Raquel Souza on 11/11/26.
//

import Foundation
import Testing
@testable import ChallengeFinal

@Suite("Tests for Formatters")
struct FormattersTests {

    /// Data fixa com dia de um dígito: é o caso que mostra o "01".
    private let date = Calendar(identifier: .gregorian)
        .date(from: DateComponents(year: 2026, month: 11, day: 1))!

    @Test func testingCreatedAtInPortuguese() {
        let text = Formatters.createdAt(date, locale: Locale(identifier: "pt_BR"))

        #expect(text == "01 de novembro de 2026")
    }

    @Test func testingCreatedAtInEnglish() {
        let text = Formatters.createdAt(date, locale: Locale(identifier: "en_US"))

        #expect(text == "November 01, 2026")
    }

    @Test func testingCreatedAtInSpanish() {
        let text = Formatters.createdAt(date, locale: Locale(identifier: "es_ES"))

        #expect(text == "01 de noviembre de 2026")
    }
}
