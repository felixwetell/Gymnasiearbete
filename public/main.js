function dateR(wday) {
    var day = "";
    switch (wday) {
        case 1:
            day = "Måndag";
            break;
        case 2:
            day = "Tisdag";
            break;
        case 3:
            day = "Onsdag";
            break;
        case 4:
            day = "Torsdag";
            break;
        case 5:
            day = "Fredag";
            break;
        case 6:
            day = "Lördag";
            break;
        case 0:
            day = "Söndag";
            break;
    }
    return day
}

