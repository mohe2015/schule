/*
 schule-server - provides a simplified version of the substitution schedule
 Copyright (C) 2017 Moritz Hedtke

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program. If not, see <http://www.gnu.org/licenses/>.

 E-Mail: Moritz.Hedtke@t-online.de
 */
#include "Vertretung.hpp"
#include "Utils.hpp"
#include <iostream>
#include <map>
#include <sstream>

std::string Vertretung::parseFach(const std::string &fach) {
    std::map<std::string, std::string> faecher;
    faecher["E"] = "Englisch";
    faecher["D"] = "Deutsch";
    faecher["Ch"] = "Chemie";
    faecher["KL-St"] = "Klassenlehrer-Stunde";
    faecher["M"] = "Mathe";
    faecher["Mu"] = "Musik";
    faecher["PW"] = "PoWi";
    faecher["F"] = "Französisch";
    faecher["G"] = "Geschichte";
    faecher["WPU"] = "Wahlpflichtunterricht";
    faecher["Ph"] = "Physik";
    faecher["Spo"] = "Sport";
    faecher["Ek"] = "Erdkunde";
    faecher["AL"] = "Arbeitslehre";
    faecher["L"] = "Latein";
    faecher["B"] = "Biologie";
    faecher["ev"] = "evangelische Religion";
    faecher["kat"] = "katholische Religion";
    faecher["WPU-F"] = "Wahlpflichtunterricht Französisch";
    faecher["Ku"] = "Kunst";
    faecher["Spa"] = "Spanisch";
    faecher["GL"] = "Gesellschaftslehre";
    std::string longName = faecher[fach];
    if (longName.empty()) {
        longName = fach;
    }
    return longName;
}

std::ostream &operator<<(std::ostream &os, const Vertretung &vertretung) {
    std::stringstream humanReadable;
    humanReadable << vertretung.stunde << ". " << vertretung.alterLehrer;
    if (!vertretung.neuesFach.empty()) {
        humanReadable << " stattdessen " << Vertretung::parseFach(vertretung.neuesFach);
    }
    if (!vertretung.neuerLehrer.empty()) {
        humanReadable << " bei " << vertretung.neuerLehrer;
    }
    if (!vertretung.neuerRaum.empty()) {
        humanReadable << " in " << vertretung.neuerRaum;
    }
    if (!vertretung.notizen.empty()) {
        humanReadable << " " << vertretung.notizen;
    }
    os << "{\"human-readable\": \"" << humanReadable.str() << "\", " << "\"humand-readable\": \"" << humanReadable.str() << "\", ";
    os << "\"stunde\": \"" << vertretung.stunde << "\", \"kurs\": \"" << vertretung.kurs << "\", \"alterLehrer\": \"" << vertretung.alterLehrer
       << "\", \"neuerLehrer\": \"" << vertretung.neuerLehrer << "\", \"alterRaum\": \"" << vertretung.alterRaum << "\", \"neuerRaum\": \""
       << vertretung.neuerRaum << "\", \"altesFach\": \"" << vertretung.altesFach << "\", \"neuesFach\": \"" << vertretung.neuesFach
       << "\", \"notizen\": \"" << vertretung.notizen << "\"}";
    return os;
}
