// The script below is used to show what weekday it is as a "Swedish String".

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

// The script below is used to create tables on the fly.
// This allows us to Filter the Event Info content on the fly
// in order to show the Event Info for the specific selected day.

var date = "";
function filter(date) {
    $(".generated_tr").remove(); // Removing the current Event Filter content (all the generated tr and it's children)
    for (var i = 0; i < usernames_from_events.length; i++) {
        if (date == event_date_from_events[i]) {
            var table_row = document.createElement("tr");// Creating a table tr
            table_row.className = "generated_tr";        // Adding class name to enable removing the tr

            var td_name = document.createElement("td");         // Creating a table td
            td_name.innerHTML = usernames_from_events[i];       // Adding data to the table td

            var td_type = document.createElement("td");
            td_type.innerHTML = event_types_from_events[i];

            var td_location = document.createElement("td");
            td_location.innerHTML = event_locations_from_events[i];

            var td_time_from = document.createElement("td");
            td_time_from.innerHTML = event_times_from_from_events[i];

            var td_time_to = document.createElement("td");
            td_time_to.innerHTML = event_times_to_from_events[i];

            var td_time_change = document.createElement("td");
            td_time_change.innerHTML = event_time_changes_from_events[i];

            table_row.appendChild(td_name);                     // Adding the td to the tr
            table_row.appendChild(td_type);
            table_row.appendChild(td_location);
            table_row.appendChild(td_time_from);
            table_row.appendChild(td_time_to);
            table_row.appendChild(td_time_change);
            //table_row.appendChild(td_date);
            document.getElementById('event_info_table').appendChild(table_row); // Adding the tr to the table
        }
    }
}

function showFriends(friendsArray) {
    console.log("yep");
    for (var i = 0; i < friendsArray.length; i++) {
            var table_row = document.createElement("tr");   // Creating a table tr

            var td_friend = document.createElement("td");     // Creating a table td
            td_friend.innerHTML = friendsArray[i];            // Adding data to the table td

            table_row.appendChild(td_friend);                 // Adding the td to the tr
            document.getElementById('friends_div').appendChild(table_row); // Adding the tr to the table
    }
}