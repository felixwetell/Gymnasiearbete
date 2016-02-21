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

var date = "";
function filter(date) {
    for (var i = 0; i < usernames_from_events.length; i++) {
        if (date == event_date_from_events[i]) {
            var table_row = document.createElement("tr");       // Creating a table tr

            var td_name = document.createElement("td");         // Creating a table td
            td_name.innerHTML = usernames_from_events[i];     // Adding data to the table td

            var td_type = document.createElement("td");
            td_type.innerHTML = event_types_from_events[i];
            // td_type.className='name';        exempel på classchange
            // td_type.style.margin='10px';     exempel på stylechange

            var td_location = document.createElement("td");
            td_location.innerHTML = event_locations_from_events[i];

            var td_time_from = document.createElement("td");
            td_time_from.innerHTML = event_times_from_from_events[i];

            var td_time_to = document.createElement("td");
            td_time_to.innerHTML = event_times_to_from_events[i];

            var td_time_change = document.createElement("td");
            td_time_change.innerHTML = event_time_changes_from_events[i];

            var td_date = document.createElement("td");
            td_date.innerHTML = event_date_from_events[i];

            table_row.appendChild(td_name);                     // Adding the td to the tr
            table_row.appendChild(td_type);
            table_row.appendChild(td_location);
            table_row.appendChild(td_time_from);
            table_row.appendChild(td_time_to);
            table_row.appendChild(td_time_change);
            table_row.appendChild(td_date);
            document.getElementById('event_info_table').appendChild(table_row); // Adding the tr to the table
        }
    }
}