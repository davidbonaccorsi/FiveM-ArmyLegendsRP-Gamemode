local codes = {
    {code = "10-0", name = "Suspect pierdut"},
    {code = "10-1", name = "Schimbare frecventa Radio"},
    {code = "10-2", name = "Permisiune Depasire"},
    {code = "10-4", name = "Receptionat"},
    {code = "10-8", name = "In patrula"},
    {code = "10-9", name = "Repeta"},
    {code = "10-11", name = "Focuri de arma"},
    {code = "10-16", name = "Masina fara nr. inmatriculare"},
    {code = "10-20", name = "Locatie"},
    {code = "10-23", name = "Ajuns la destinatie"},
    {code = "10-28", name = "Numere de inmatriculare"},
    {code = "10-38", name = "Traffic Stop"},
    {code = "10-41", name = "On Duty"},
    {code = "10-42", name = "Off Duty"},
    {code = "10-50", name = "Accident"},
    {code = "10-60", name = "Livrare in progres"},
    {code = "10-74", name = "Negativ"},
    {code = "10-76", name = "In drum spre"},
    {code = "10-78", name = "Necesit Echipaje Aditionale"},
    {code = "10-80", name = "Urmarire in desfasurare"},
    {code = "10-95", name = "Suspect in custodie"},
}

RegisterNUICallback('search:code', function(data, cb)
    cb(codes)
end)