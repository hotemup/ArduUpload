// Config parameters
var default_pan = [40.484845, -74.436724];
var default_zoom = 10;
var seconds_before = 60*60*6;
var seconds_after = 60;
var default_progression_length = 60*60*24;
var update_interval = 2;
var backend_url = 'http://172.31.76.213/~jesse/backend.sh';

// Globals
var map;
var markers = [];
var mode;
var mode_order = ['none', 'block'];
var req;

var inst_container;
var prog_container;
var instant;
var prog_0;
var prog_1;

function update_markers() {
	if (req != null)
		req.abort();

	req = new XMLHttpRequest();
	req.open('GET', backend_url);
	req.onreadystatechange = function() {
		if (req.readyState == 4)
		{
			// Parse JSON data
			var entries = req.responseText.split("\n");
			var parsed = [];

			for (var i = 0; i < entries.length; i ++)
				if (entries[i].length > 0)
				{
					var json = JSON.parse(entries[i]);
					var t0 = Date.parse((mode == 'progressive') ? prog_0.value : instant.value);
					var t1 = (mode == 'progressive') ? Date.parse(prog_1.value) : t0;

					if (t0 - seconds_before*1000 < json.timestamp && json.timestamp < t1 + seconds_after*1000)
						parsed.push(json);
				}

			parsed.sort(function(a, b) {
				if (a.timestamp < b.timestamp)
					return -1;
				else
					return 1;
			});

			// Clear existing markers
			for (var i = 0; i < markers.length; i ++)
				if (markers[i] != null)
					markers[i].setMap(null);
			markers = [];

			// Draw new markers
			var users = {};
			for (var i = 0; i < parsed.length; i ++)
			{
				var new_pos = new google.maps.LatLng(parsed[i].lat, parsed[i].lon);
				if (typeof(users[parsed[i].user]) != 'undefined')
				{
					if (mode == 'instant') // Remove user's previous location
					{
						markers[users[parsed[i].user]].setMap(null);
						markers[users[parsed[i].user]] = null;
					}
					else // Draw arrows
					{
						markers.push(new google.maps.Polyline({
							path: [markers[users[parsed[i].user]].getPosition(), new_pos],
							icons: [{
								icon: {path: google.maps.SymbolPath.FORWARD_CLOSED_ARROW},
								offset: '100%'
							}],
							map: map
						}));
					}
				}

				users[parsed[i].user] = markers.length;
				markers.push(new google.maps.Marker({
					position: new_pos,
					title: parsed[i].user,
					map: map
				}));
			}
			req = null;
		}
	};
	req.send();
}

window.setInterval(update_markers, update_interval*1000);

function changemode()
{
	inst_container.style.display = mode_order[0];
	prog_container.style.display = mode_order[1];

	mode = (mode_order[0] == 'block') ? 'instant' : 'progressive';
	mode_order.reverse();
	update_markers();
}

onload = function() {
	map = new google.maps.Map(document.getElementById('map_canvas'), {
		center: new google.maps.LatLng(default_pan[0], default_pan[1]),
		zoom: default_zoom,
		mapTypeId: google.maps.MapTypeId.ROADMAP
	});

	inst_container = document.getElementById('inst_container');
	prog_container = document.getElementById('prog_container');
	instant = document.getElementById('instant');
	prog_0 = document.getElementById('prog_0');
	prog_1 = document.getElementById('prog_1');

	var date = new Date();
	instant.value = date.toLocaleString();

	date.setTime(date.getTime() - default_progression_length*1000);
	prog_0.value = date.toLocaleString();
	prog_1.value = instant.value;
	changemode();
};
