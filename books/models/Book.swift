//
//  Book.swift
//  books
//
//  Created by user on 15.05.24.
//

import Foundation

enum Tag: String {
    case fiction = "FICTION"
    case thriller = "THRILLER"
    case romance = "ROMANCE"
    case fantasy = "FANTASY"
    case scienceFiction = "SCIENCE_FICTION"
    case classics = "CLASSICS"
    case dystopia = "DYSTOPIA"
    case racism = "RACISM"
    case adventure = "ADVENTURE"
    case comingOfAge = "COMING_OF_AGE"
    case magic = "MAGIC"
    case psychological = "PSYCHOLOGICAL"
    case survival = "SURVIVAL"
    case spiritual = "SPIRITUAL"
    case magicalRealism = "MAGICAL_REALISM"
    case historicalFiction = "HISTORICAL_FICTION"
    case gothic = "GOTHIC"
    case war = "WAR"
    case contemporary = "CONTEMPORARY"
    case youngAdult = "YOUNG_ADULT"
    case horror = "HORROR"
    case feminism = "FEMINISM"
    case mystery = "MYSTERY"
}

struct Book {
    let name: String
    let author: String
    let tags: [Tag]
}
