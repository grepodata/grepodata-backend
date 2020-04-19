{literal}
// ==UserScript==
// @name         grepodata city indexer {/literal}{$key}{literal}
// @namespace    grepodata
// @version      {/literal}{$version}{literal}
// @author       grepodata.com
// @updateURL    https://api.grepodata.com/userscript/cityindexer_{/literal}{$encrypted}{literal}.user.js
// @downloadURL	 https://api.grepodata.com/userscript/cityindexer_{/literal}{$encrypted}{literal}.user.js
// @description  This script allows you to easily collect enemy intelligence in your own private index
// @include      https://{/literal}{$world}{literal}.grepolis.com/game/*
// @include      https://grepodata.com*
// @exclude      view-source://*
// @icon         https://grepodata.com/assets/images/grepodata_icon.ico
// @copyright	 2016+, grepodata.com
// @grant        none
// ==/UserScript==

(function() { try {
    // Stop Greasemonkey execution. Only Tampermonkey can run this script
    if ('undefined' === typeof GM_info.script.author) {
        //alert("You installed the GrepoData city indexer using Greasemonkey. This does not work. Please install it using Tampermonkey and remove the script from your Greasemonkey plugin.");
        throw new Error("Stopped greasemonkey execution for grepodata city indexer. Please use Tampermonkey instead");
    }

    // Script parameters
    var gd_version = "{/literal}{$version}{literal}";
    var index_key = "{/literal}{$key}{literal}";
    var index_hash = "{/literal}{$encrypted}{literal}";
    var world = "{/literal}{$world}{literal}";
	var verbose = false;

    if (window.jQuery) {
    } else {
        var script = document.createElement('script');
        script.src = 'https://code.jquery.com/jquery-2.1.4.min.js';
        script.type = 'text/javascript';
        document.getElementsByTagName('head')[0].appendChild(script);
    }

    function loadCityIndex(key, globals) {

        // Globals
        var time_regex = /([0-5]\d)(:)([0-5]\d)(:)([0-5]\d)(?!.*([0-5]\d)(:)([0-5]\d)(:)([0-5]\d))/gm;
        var gd_icon = "url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABoAAAAXCAYAAAAV1F8QAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAAYdEVYdFNvZnR3YXJlAHBhaW50Lm5ldCA0LjAuNvyMY98AAAG0SURBVEhLYwACASA2AGIHGmGQ2SA7GGzf7oj4//5g7v/3B7L+vz+U///NVv//r9ZY/3+7K/b/683e/9/tSSTIf7M9DGhGzv8PR4r/v9uX9v/D0TKw+MdTzf9BdoAsSnm13gnEoQn+dLYLRKcAMUPBm62BYMH/f/9QFYPMfL3JE0QXQCzaFkIziz6d60FYBApvdIt07AJQ+ORgkJlfrs2DW1T9ar0jxRZJ7JkDxshiIDPf744B0dUgiwrebA8l2iJsBuISB5l5q58dREOC7u3OKJpZdHmKEsKi1xvdybIIpAamDpdFbze5ISzClrypZdGLZboIiz6d7cRrES4DibHozdYghEWfL0ygmUVvtwcjLPpwuJBmFj1ZpImw6N3uBNpZNE8ByaK9KXgtIheDzHy12gJuUfG7falYLSIHI5sBMvPlCiMQXQy2CFQPoVtEDQwy88VScByBLSqgpUVQH0HjaH8GWJAWGFR7A2mwRSkfjlUAM1bg/9cbXMAVFbhaBib5N9uCwGxQdU2ID662T9aDMag5AKrOQVX9u73JIIvANSyoPl8CxOdphEFmg9sMdGgFMQgAAH4W0yWXhEbUAAAAAElFTkSuQmCC')";
		var gd_icon_intel = "url('data:image/png;base64,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')";
		var gd_icon_svg = '<svg aria-hidden="true" data-prefix="fas" data-icon="university" class="svg-inline--fa fa-university fa-w-16" role="img" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" style="color: #18bc9c; width: 18px;"><path fill="currentColor" d="M496 128v16a8 8 0 0 1-8 8h-24v12c0 6.627-5.373 12-12 12H60c-6.627 0-12-5.373-12-12v-12H24a8 8 0 0 1-8-8v-16a8 8 0 0 1 4.941-7.392l232-88a7.996 7.996 0 0 1 6.118 0l232 88A8 8 0 0 1 496 128zm-24 304H40c-13.255 0-24 10.745-24 24v16a8 8 0 0 0 8 8h464a8 8 0 0 0 8-8v-16c0-13.255-10.745-24-24-24zM96 192v192H60c-6.627 0-12 5.373-12 12v20h416v-20c0-6.627-5.373-12-12-12h-36V192h-64v192h-64V192h-64v192h-64V192H96z"></path></svg>';

        // Settings
        var gd_settings = {
            inbox: true,
            forum: true,
            stats: true,
			context: true,
            keys_enabled: true,
            cmdoverview: false,
            key_inbox_prev: '[',
            key_inbox_next: ']',
        };
        readSettingsCookie();
        setTimeout(function () {
            if (gd_settings.inbox === true || gd_settings.forum === true) {
                loadIndexHashlist(false);
            }
        }, 1000);
        setTimeout(function () {
            if (gd_settings.cmdoverview === true) {
                readIntelHistory();
            }
        }, 500);

        // Set locale
        var translate = {
            ADD: 'Index',
            SEND: 'sending..',
            ADDED: 'Indexed',
            VIEW: 'View intel',
            TOWN_INTEL: 'Town intelligence',
            STATS_LINK: 'Show buttons that link to player/alliance statistics on grepodata.com',
            STATS_LINK_TITLE: 'Link to statistics',
            CHECK_UPDATE: 'Check for updates',
            ABOUT: 'This tool allows you to collect and browse enemy city intelligence from your very own private index that can be shared with your alliance',
            INDEX_LIST: 'You are currently contributing intel to the following indexes',
            COUNT_1: 'You have contributed ',
            COUNT_2: ' reports in this session',
            SHORTCUTS: 'Keyboard shortcuts',
            SHORTCUTS_ENABLED: 'Enable keyboard shortcuts',
            SHORTCUTS_INBOX_PREV: 'Previous report (inbox)',
            SHORTCUTS_INBOX_NEXT: 'Next report (inbox)',
            COLLECT_INTEL: 'Collecting intel',
            COLLECT_INTEL_INBOX: 'Inbox (adds an "index+" button to inbox reports)',
            COLLECT_INTEL_FORUM: 'Alliance forum (adds an "index+" button to alliance forum reports)',
            SHORTCUT_FUNCTION: 'Function',
            SAVED: 'Settings saved',
            SHARE: 'Share',
            CMD_OVERVIEW_TITLE: 'Enhanced command overview (BETA)',
            CMD_OVERVIEW_INFO: 'Enhance your command overview with unit intelligence from your enemy city index. Note: this is a new feature, currently still in development. Please contact us if you have feedback.',
            CONTEXT_TITLE: 'Expand context menu',
            CONTEXT_INFO: 'Add an intel shortcut to the town context menu. The shortcut opens the intel for this town.',
        };
        if ('undefined' !== typeof Game) {
            switch (Game.locale_lang.substring(0, 2)) {
                case 'nl':
                    translate = {
                        ADD: 'Indexeren',
                        SEND: 'bezig..',
                        ADDED: 'Geindexeerd',
                        VIEW: 'Intel bekijken',
                        TOWN_INTEL: 'Stad intel',
                        STATS_LINK: 'Knoppen toevoegen die linken naar speler/alliantie statistieken op grepodata.com',
                        STATS_LINK_TITLE: 'Link naar statistieken',
                        CHECK_UPDATE: 'Controleer op updates',
                        ABOUT: 'Deze tool verzamelt informatie over vijandige steden in een handig overzicht. Rapporten kunnen geindexeerd worden in een unieke index die gedeeld kan worden met alliantiegenoten',
                        INDEX_LIST: 'Je draagt momenteel bij aan de volgende indexen',
                        COUNT_1: 'Je hebt al ',
                        COUNT_2: ' rapporten verzameld in deze sessie',
                        SHORTCUTS: 'Toetsenbord sneltoetsen',
                        SHORTCUTS_ENABLED: 'Sneltoetsen inschakelen',
                        SHORTCUTS_INBOX_PREV: 'Vorige rapport (inbox)',
                        SHORTCUTS_INBOX_NEXT: 'Volgende rapport (inbox)',
                        COLLECT_INTEL: 'Intel verzamelen',
                        COLLECT_INTEL_INBOX: 'Inbox (voegt een "index+" knop toe aan inbox rapporten)',
                        COLLECT_INTEL_FORUM: 'Alliantie forum (voegt een "index+" knop toe aan alliantie forum rapporten)',
                        SHORTCUT_FUNCTION: 'Functie',
                        SAVED: 'Instellingen opgeslagen',
                        SHARE: 'Delen',
                        CMD_OVERVIEW_TITLE: 'Uitgebreid beveloverzicht (BETA)',
                        CMD_OVERVIEW_INFO: 'Voeg troepen intel uit je city index toe aan het beveloverzicht. Let op: dit is een nieuwe feature, momenteel nog in ontwikkeling. Contacteer ons als je feedback hebt.',
						CONTEXT_TITLE: 'Context menu uitbreiden',
						CONTEXT_INFO: 'Voeg een intel snelkoppeling toe aan het context menu. De snelkoppeling verwijst naar de verzamelde intel van de stad.',
                    };
                    break;
                default:
                    break;
            }
        }

        // Scan for inbox reports
        function parseInbox() {
            if (gd_settings.inbox === true) {
                parseInboxReport();
            }
        }
        setInterval(parseInbox, 500);

        // Listen for game events
        $(document).ajaxComplete(function (e, xhr, opt) {
			try {
				var url = opt.url.split("?"), action = "";
				if (typeof(url[1]) !== "undefined" && typeof(url[1].split(/&/)[1]) !== "undefined") {
					action = url[0].substr(5) + "/" + url[1].split(/&/)[1].substr(7);
				}
				if (verbose) {
					console.log(action);
				}
				switch (action) {
					case "/town_overviews/command_overview":
						if (gd_settings.cmdoverview === true) {
							setTimeout(enhanceCommandOverview, 20);
						}
					case "/report/view":
						// Parse reports straight from inbox
						parseInbox();
						break;
					case "/town_info/info":
						viewTownIntel(xhr);
						break;
					case "/message/view": // catch inbox previews
					case "/message/preview": // catch inbox messages
					case "/alliance_forum/forum": // catch forum messages
						// Parse reports from forum and messages
						if (gd_settings.forum === true) {
							setTimeout(parseForumReport, 200);
						}
						break;
					case "/player/index":
						settings();
						break;
					case "/player/get_profile_html":
					case "/alliance/profile":
						linkToStats(action, opt);
						break;
				}
			} catch (e) {
				console.error(e);
			}
        });

        function readSettingsCookie() {
            var settingsJson = localStorage.getItem('gd_city_indexer_s');
            if (settingsJson != null) {
                result = JSON.parse(settingsJson);
                if (result != null) {
                    result.forum = result.forum === false ? false : true;
                    result.inbox = result.inbox === false ? false : true;
                    if (!('stats' in result)) {
                        result.stats = true;
                    }
                    if (!('context' in result)) {
                        result.context = true;
                    }
                    if (!('cmdoverview' in result)) {
                        result.cmdoverview = false;
                    }
                    gd_settings = result;
                }
            }
        }

		// Expand context menu
		$.Observer(GameEvents.map.town.click).subscribe(async (e, data) => {
			try {
				if (gd_settings.context && data && data.id) {
					if (!data.player_id || data.player_id != Game.player_id) {
						expandContextMenu(data.id, (data.name?data.name:''), (data.player_name?data.player_name:''));
					}
				}
			} catch (e) {
				console.error(e);
			}
		});
		$.Observer(GameEvents.map.context_menu.click).subscribe(async (e) => {
			try {
				if (gd_settings.context && e.currentTarget && e.currentTarget.activeElement && e.currentTarget.activeElement.hash) {
					var data = decodeHashToJson(e.currentTarget.activeElement.hash);
					if (data.id && data.name) {
						expandContextMenu(data.id, data.name, '');
					}
				}
			} catch (e) {
				console.error(e);
			}
		});
		function expandContextMenu(town_id, town_name, player_name = '') {
			var intelHtml = '<div id="gd_context_intel" class="context_icon" style="z-index: 4; background: ' + gd_icon_intel + ';">'+
				'<div class="icon_caption"><div class="top"></div><div class="middle"></div><div class="bottom"></div><div class="caption">Intel</div></div></div>';
			//var intelHtml = '<div id="gd_context_intel" class="context_icon" style="z-index: 4; background: ' + gd_icon + '; background-repeat: no-repeat; top: 19px; transform: scale(1.5);">'+
				//'<div class="icon_caption" style="transform: scale(.6); left: 41px; top: 15px; width: 60px;"><div class="top"></div><div class="middle"></div><div class="bottom"></div><div class="caption">Intel</div></div></div>';
			var menuItems = $("#context_menu").find('.context_icon');
			if (!menuItems || menuItems.length >= 5) {
				$("#context_menu").append(intelHtml);
				$("#gd_context_intel").animate({top: (menuItems.length>5?100:120)+'px'}, 120);
				//$("#gd_context_intel").animate({left: '140px'}, 120);
				$('#gd_context_intel').click(function() {
					loadTownIntel(town_id, town_name, player_name);
				});
			}
		}

        // Enhance command overview
        var parsedCommands = {};
		var bParsingEnabledTemp = true;
        function enhanceCommandOverview() {
			// Add temp filter button to footer
            var gd_filter = document.getElementById('gd_cmd_filter');
			if (!gd_filter) {
				var commandFilters = $('#command_filter').get(0);
				var filterHtml = '<div id="gd_cmd_filter" class="support_filter" style="background-image: '+gd_icon+'; width: 26px; height: 26px; '+(bParsingEnabledTemp?'':'opacity: 0.3;')+'"></div>';
				$(commandFilters).find('> div').append(filterHtml);

				$('#gd_cmd_filter').click(function() {
					bParsingEnabledTemp = !bParsingEnabledTemp;
					if (!bParsingEnabledTemp) {
						$('.gd_cmd_units').remove();
						$(this).css({ opacity: 0.3 });
					} else {
						$(this).css({ opacity: 1 });
						enhanceCommandOverview();
					}
				});
			}

			// Parse overview
			if (bParsingEnabledTemp) {
				//let movements = Object.values(MM.getModels().MovementsUnits);
				//console.log(movements);

				var commandList = $('#command_overview').get(0);
				var commands = $(commandList).find('li');
				var parseLimit = 100; // Limit number of parsed commands
				commands.each(function (c) {
					if (c>=parseLimit) {return}
					try {
						var command_id = this.id;
						if (parsedCommands[command_id]) {
							if (parsedCommands[command_id].is_enemy) {
								enhanceCommand(command_id);
							}
						} else {
							//var id = command_id.match(/\d+/)[0];
							//var arrival_time = $(this).find('.eta-arrival-'+id).get(0).innerText.match(/([01]?[0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]/)[0];
							var cmd_units = $(this).find('.command_overview_units');
							if (cmd_units.length != 0) {
								parsedCommands[command_id] = {is_enemy: false};
							} else {
								// Command is incoming enemy, parse ids
								var cmd_span = $(this).find('.cmd_span').get(0);
								var cmd_ents = $(cmd_span).find('a');
								if (cmd_ents.length == 4) {
									var prev_town = null;
									var cmd_town = null;
									var cmd_player = null;
									cmd_ents.each(function (t) {
										var hash = this.hash;
										var data = decodeHashToJson(hash);
										if (this.className == 'gp_town_link') {
											prev_town = data;
										} else if (this.className == 'gp_player_link' && prev_town != null) {
											if (Game.player_id != data.id) {
												cmd_town = prev_town;
												cmd_player = data;
											}
										}
									});
									parsedCommands[command_id] = {town: cmd_town, player: cmd_player, is_enemy: true};
									enhanceCommand(command_id);
								}
							}
						}
					} catch (e) {
						console.error("Unable to parse command: ", e);
					}
				});

				$('.gd_cmd_units').tooltip('Town intel (GrepoData index)');
			}
        }

        function enhanceCommand(id, force=false) {
            var cmd = parsedCommands[id];
            var cmd_units = document.getElementById('gd_cmd_units_'+id);
            if (!cmd_units || force) {
                if (cmd_units && force) {
                    $('#gd_cmd_units_'+id).remove();
                }
				var cmdInfoBox = $('#'+id).find('.cmd_info_box');
                var intel = townIntelHistory[cmd.town.id];
                if (typeof intel !== "undefined") {
                    // show town intel from memory
                    if ('u' in intel && Object.keys(intel.u).length > 0) {
						var cmdInfoWidth = cmdInfoBox.width();
						var freeSpace = 770 - cmdInfoWidth - 60; // cmdWidth - cmdTextWidth - margin
						var numUnits = Object.keys(intel.u).length;
						var unitSpace = numUnits * 29;
						var bUnitsFit = freeSpace > unitSpace;
						if (!bUnitsFit) {
							$('#'+id).height(45);
						}
                        var unitHtml = '<div id="gd_cmd_units_'+id+'" class="command_overview_units gd_cmd_units" style="'+(bUnitsFit?'bottom: 3px; ':'margin-top: 18px; ')+'cursor: pointer; position: absolute; right: 0;">';
                        for (var i = 0; i < numUnits; i++) {
                            var unit = intel.u[i];
                            var size = 10;
                            switch (Math.max(unit.count.toString().length, unit.killed.toString().length)) {
                                case 1:
                                case 2:
                                    size = 11;
                                    break;
                                case 3:
                                    size = 10;
                                    break;
                                case 4:
                                    size = 8;
                                    break;
                                case 5:
                                    size = 6;
                                    break;
                                default:
                                    size = 10;
                            }
                            unitHtml = unitHtml +
                                '<div class="unit_icon25x25 ' + unit.name + '" style="overflow: unset; font-size: ' + size + 'px; text-shadow: 1px 1px 3px #000; color: #fff; font-weight: 700; border: 1px solid #626262; padding: 10px 0 0 0; line-height: 13px; height: 15px; text-align: right; margin-right: 2px;">' +
                                unit.count + '</div>';
                        }
                        unitHtml = unitHtml + '</div>';
                        cmdInfoBox.after(unitHtml);
                    } else {
                        var units = '<div id="gd_cmd_units_'+id+'" class="command_overview_units gd_cmd_units" style="margin-top: 14px; cursor: pointer;"><span style="font-size: 10px;">No intel > </span></div>';
                        cmdInfoBox.after(units);
                    }

                } else {
                    // show a shortcut to view town intel
                    var units = '<div id="gd_cmd_units_'+id+'" class="command_overview_units gd_cmd_units" style="margin-top: 14px;"><a id="gd_cmd_intel_'+id+'" style="font-size: 10px;">Check intel > </a></div>';
                    cmdInfoBox.after(units);
                }

                $('#gd_cmd_units_'+id).click(function () {
                    loadTownIntel(cmd.town.id, cmd.town.name, cmd.player.name, id);
                });

            }

        }

        // Decode entity hash
        function decodeHashToJson(hash) {
            // Remove hashtag prefix
            if (hash.slice(0, 1) === '#') {
                hash = hash.slice(1);
            }
            // Remove trailing =
            for (var g = 0; g < 10; g++) {
                if (hash.slice(hash.length - 1) === '=') {
                    hash = hash.slice(0, hash.length - 1)
                }
            }

            var data = atob(hash);
            var json = JSON.parse(data);

			if (verbose) {
				console.log("parsed from hash " + hash, json);
			}
            return json;
        }

        // Encode entity hash
        function encodeJsonToHash(json) {
			var hash = btoa(JSON.stringify(json));
			if (verbose) {
				console.log("parsed to hash " + hash, json);
			}
			return hash;
        }

		// Create town hash
		function getTownHash(id, name='', x=0, y=0) {
			return encodeJsonToHash({
				id: id,
				ix: x,
				iy: y,
				tp: 'town',
				name: name
			});
		}

		// Create player hash
		function getPlayerHash(id, name) {
			return encodeJsonToHash({
				id: id,
				name: name
			});
		}

        // settings btn
        var gdsettings = false;
        $('.gods_area').append('<div class="btn_settings circle_button gd_settings_icon" style="right: 0px; top: 95px; z-index: 10;">\n' +
            '\t<div style="margin: 7px 0px 0px 4px; width: 24px; height: 24px;">\n' +
            '\t'+gd_icon_svg+'\n' +
            '\t</div>\n' +
            '<span class="indicator" id="gd_index_indicator" data-indicator-id="indexed" style="background: #182B4D;display: none;z-index: 10000; position: absolute;bottom: 18px;right: 0px;border: solid 1px #ffca4c; height: 12px;color: #fff;font-size: 9px;border-radius: 9px;padding: 0 3px 1px;line-height: 13px;font-weight: 400;">0</span>' +
            '</div>');
        $('.gd_settings_icon').click(function () {
            if (!GPWindowMgr.getOpenFirst(Layout.wnd.TYPE_PLAYER_SETTINGS)) {
                gdsettings = true;
            }
            Layout.wnd.Create(GPWindowMgr.TYPE_PLAYER_SETTINGS, 'Settings');
            setTimeout(function () {
                gdsettings = false
            }, 5000)
        });
        $('.gd_settings_icon').tooltip('GrepoData City Indexer ' + key);

        // report info is converted to a 32 bit hash to be used as unique id
        String.prototype.report_hash = function () {
            var hash = 0, i, chr;
            if (this.length === 0) return hash;
            for (i = 0; i < this.length; i++) {
                chr = this.charCodeAt(i);
                hash = ((hash << 5) - hash) + chr;
                hash |= 0;
            }
            return hash;
        };

        // Add the given forum report to the index
        function addToIndexFromForum(reportId, reportElement, reportPoster, reportHash) {
            var reportJson = JSON.parse(mapDOM(reportElement, true));
            var reportText = reportElement.innerText;

            var data = {
                'key': globals.gdIndexScript,
                'type': 'default',
                'report_hash': reportHash || '',
                'report_text': reportText,
                'report_json': reportJson,
                'script_version': gd_version,
                'report_poster': reportPoster,
                'report_poster_id': gd_w.Game.player_id || 0
            };

            $('.rh' + reportHash).each(function () {
                $(this).css("color", '#36cd5b');
                $(this).find('.middle').get(0).innerText = translate.ADDED + ' ✓';
                $(this).off("click");
            });
            $.ajax({
                url: "https://api.grepodata.com/indexer/addreport",
                data: data,
                type: 'post',
                crossDomain: true,
                dataType: 'json',
                success: function (data) {
                },
                error: function (jqXHR, textStatus) {
                    console.log("error saving forum report");
                },
                timeout: 120000
            });
            pushForumHash(reportHash);
            gd_indicator();
        }

        // Add the given inbox report to the index
        function addToIndexFromInbox(reportHash, reportElement) {
            var reportJson = JSON.parse(mapDOM(reportElement, true));
            var reportText = reportElement.innerText;

            var data = {
                'key': globals.gdIndexScript,
                'type': 'inbox',
                'report_hash': reportHash,
                'report_text': reportText,
                'report_json': reportJson,
                'script_version': gd_version,
                'report_poster': gd_w.Game.player_name || '',
                'report_poster_id': gd_w.Game.player_id || 0,
                'report_poster_ally_id': gd_w.Game.alliance_id || 0,
            };

            if (gd_settings.inbox === true) {
                var btn = document.getElementById("gd_index_rep_txt");
                var btnC = document.getElementById("gd_index_rep_");
                btnC.setAttribute('style', 'color: #36cd5b; float: right;');
                btn.innerText = translate.ADDED + ' ✓';
            }
            $.ajax({
                url: "https://api.grepodata.com/indexer/inboxreport",
                data: data,
                type: 'post',
                crossDomain: true,
                success: function (data) {
                },
                error: function (jqXHR, textStatus) {
                    console.log("error saving inbox report");
                },
                timeout: 120000
            });
            pushInboxHash(reportHash);
            gd_indicator();
        }

        function pushInboxHash(hash) {
            if (globals.reportsFoundInbox === undefined) {
                globals.reportsFoundInbox = [];
            }
            globals.reportsFoundInbox.push(hash);
        }

        function pushForumHash(hash) {
            if (globals.reportsFoundForum === undefined) {
                globals.reportsFoundForum = [];
            }
            globals.reportsFoundForum.push(hash);
        }

        function mapDOM(element, json) {
            var treeObject = {};

            // If string convert to document Node
            if (typeof element === "string") {
                if (window.DOMParser) {
                    parser = new DOMParser();
                    docNode = parser.parseFromString(element, "text/xml");
                } else { // Microsoft strikes again
                    docNode = new ActiveXObject("Microsoft.XMLDOM");
                    docNode.async = false;
                    docNode.loadXML(element);
                }
                element = docNode.firstChild;
            }

            //Recursively loop through DOM elements and assign properties to object
            function treeHTML(element, object) {
                object["type"] = element.nodeName;
                var nodeList = element.childNodes;
                if (nodeList != null) {
                    if (nodeList.length) {
                        object["content"] = [];
                        for (var i = 0; i < nodeList.length; i++) {
                            if (nodeList[i].nodeType == 3) {
                                object["content"].push(nodeList[i].nodeValue);
                            } else {
                                object["content"].push({});
                                treeHTML(nodeList[i], object["content"][object["content"].length - 1]);
                            }
                        }
                    }
                }
                if (element.attributes != null) {
                    if (element.attributes.length) {
                        object["attributes"] = {};
                        for (var i = 0; i < element.attributes.length; i++) {
                            object["attributes"][element.attributes[i].nodeName] = element.attributes[i].nodeValue;
                        }
                    }
                }
            }

            treeHTML(element, treeObject);

            return (json) ? JSON.stringify(treeObject) : treeObject;
        }

        // Inbox reports
        function parseInboxReport() {
            var reportElement = document.getElementById("report_report");
            if (reportElement != null) {
                var footerElement = reportElement.getElementsByClassName("game_list_footer")[0];
                var reportText = reportElement.outerHTML;
                var footerText = footerElement.outerHTML;
                if (footerText.indexOf('gd_index_rep_') < 0
                    && reportText.indexOf('report_town_bg_quest') < 0
                    && reportText.indexOf('support_report_cities') < 0
                    && reportText.indexOf('big_horizontal_report_separator') < 0
                    && reportText.indexOf('report_town_bg_attack_spot') < 0
                    && (reportText.indexOf('/images/game/towninfo/support.png') < 0 || reportText.indexOf('flagpole ghost_town') < 0)
                    && (reportText.indexOf('/images/game/towninfo/attack.png') >= 0
                        || reportText.indexOf('/images/game/towninfo/espionage') >= 0
                        || reportText.indexOf('/images/game/towninfo/breach.png') >= 0
                        || reportText.indexOf('/images/game/towninfo/attackSupport.png') >= 0
                        || reportText.indexOf('/images/game/towninfo/take_over.png') >= 0
                        || reportText.indexOf('/images/game/towninfo/support.png') >= 0)
                ) {

                    // Build report hash using default method
                    var headerElement = reportElement.querySelector("#report_header");
                    var dateElement = footerElement.querySelector("#report_date");
                    var headerText = headerElement.innerText;
                    var dateText = dateElement.innerText;
                    var hashText = headerText + dateText;

                    // Try to build report hash using town ids (robust against object name changes)
                    try {
                        var towns = headerElement.getElementsByClassName('town_name');
                        if (towns.length === 2) {
                            var ids = [];
                            for (var m = 0; m < towns.length; m++) {
                                var href = towns[m].getElementsByTagName("a")[0].getAttribute("href");
                                var townJson = decodeHashToJson(href);
                                ids.push(townJson.id);
                            }
                            if (ids.length === 2) {
                                ids.push(dateText); // Add date to report info
                                hashText = ids.join('');
                            }
                        }
                    } catch (e) {
                        console.log(e);
                    }

                    // Try to parse units and buildings
                    var reportUnits = reportElement.getElementsByClassName('unit_icon40x40');
                    var reportBuildings = reportElement.getElementsByClassName('report_unit');
                    var reportContent = '';
                    try {
                        for (var u = 0; u < reportUnits.length; u++) {
                            reportContent += reportUnits[u].outerHTML;
                        }
                        for (var u = 0; u < reportBuildings.length; u++) {
                            reportContent += reportBuildings[u].outerHTML;
                        }
                    } catch (e) {
                        console.log("Unable to parse inbox report units: ", e);
                    }
                    if (typeof reportContent === 'string' || reportContent instanceof String) {
                        hashText += reportContent;
                    }

                    reportHash = hashText.report_hash();
                    console.log('Parsed inbox report with hash: ' + reportHash);

                    // Create index button
                    var addBtn = document.createElement('a');
                    var txtSpan = document.createElement('span');
                    var rightSpan = document.createElement('span');
                    var leftSpan = document.createElement('span');
                    txtSpan.innerText = translate.ADD + ' +';

                    addBtn.setAttribute('href', '#');
                    addBtn.setAttribute('id', 'gd_index_rep_');
                    addBtn.setAttribute('class', 'button gd_btn_index');
                    addBtn.setAttribute('style', 'float: right;');
                    txtSpan.setAttribute('id', 'gd_index_rep_txt');
                    txtSpan.setAttribute('style', 'min-width: 50px; margin: 0 3px;');
                    txtSpan.setAttribute('class', 'middle');
                    rightSpan.setAttribute('class', 'right');
                    leftSpan.setAttribute('class', 'left');

                    rightSpan.appendChild(txtSpan);
                    leftSpan.appendChild(rightSpan);
                    addBtn.appendChild(leftSpan);

					// Check if this report was already indexed
                    var reportFound = false;
                    for (var j = 0; j < globals.reportsFoundInbox.length; j++) {
                        if (globals.reportsFoundInbox[j] === reportHash) {
                            reportFound = true;
                        }
                    }
                    if (reportFound) {
                        addBtn.setAttribute('style', 'color: #36cd5b; float: right;');
                        txtSpan.setAttribute('style', 'cursor: default;');
                        txtSpan.innerText = translate.ADDED + ' ✓';
                    } else {
                        addBtn.addEventListener('click', function () {
                            if ($('#gd_index_rep_txt').get(0)) {
                                $('#gd_index_rep_txt').get(0).innerText = translate.SEND;
                            }
                            addToIndexFromInbox(reportHash, reportElement);
                        }, false);
                    }

					// Create share button
                    var shareBtn = document.createElement('a');
                    var shareInput = document.createElement('input');
                    var rightShareSpan = document.createElement('span');
                    var leftShareSpan = document.createElement('span');
                    var txtShareSpan = document.createElement('span');
                    shareInput.setAttribute('type', 'text');
                    shareInput.setAttribute('id', 'gd_share_rep_inp');
                    shareInput.setAttribute('style', 'float: right;');
                    txtShareSpan.setAttribute('id', 'gd_share_rep_txt');
                    txtShareSpan.setAttribute('class', 'middle');
                    txtShareSpan.setAttribute('style', 'min-width: 50px; margin: 0 3px;');
                    rightShareSpan.setAttribute('class', 'right');
                    leftShareSpan.setAttribute('class', 'left');
                    leftShareSpan.appendChild(rightShareSpan);
                    rightShareSpan.appendChild(txtShareSpan);
                    shareBtn.appendChild(leftShareSpan);
                    shareBtn.setAttribute('href', '#');
                    shareBtn.setAttribute('id', 'gd_share_rep_');
                    shareBtn.setAttribute('class', 'button gd_btn_share');
                    shareBtn.setAttribute('style', 'float: right;');

                    txtShareSpan.innerText = translate.SHARE;

                    shareBtn.addEventListener('click', () => {
                        if ($('#gd_share_rep_txt').get(0)) {
                            var hashI = ('r' + reportHash).replace('-', 'm');
                            var content = '<b>Share this report on Discord:</b><br><ul>' +
                                '    <li>1. Install the GrepoData bot in your Discord server (<a href="https://grepodata.com/discord" target="_blank">link</a>).</li>' +
                                '    <li>2. Insert the following code in your Discord server.<br/>The bot will then create the screenshot for you!' +
                                '    </ul><br/><input type="text" class="gd-copy-input-' + reportHash + '" value="' + `!gd report ${hashI}` + '"> <a href="#" class="gd-copy-command-' + reportHash + '">Copy to clipboard</a><span class="gd-copy-done-' + reportHash + '" style="display: none; float: right;"> Copied!</span>' +
                                '    <br /><br /><small>Thank you for using <a href="https://grepodata.com" target="_blank">GrepoData</a>!</small>';

                            Layout.wnd.Create(GPWindowMgr.TYPE_DIALOG).setContent(content)
                            addToIndexFromInbox(reportHash, reportElement);

                            $(".gd-copy-command-" + reportHash).click(function () {
                                $(".gd-copy-input-" + reportHash).select();
                                document.execCommand('copy');

                                $('.gd-copy-done-' + reportHash).get(0).style.display = 'block';
                                setTimeout(function () {
                                    if ($('.gd-copy-done-' + reportHash).get(0)) {
                                        $('.gd-copy-done-' + reportHash).get(0).style.display = 'none';
                                    }
                                }, 3000);
                            });
                        }
                    });

					// Create custom footer
                    var grepodataFooter = document.createElement('div');
                    grepodataFooter.setAttribute('id', 'gd_inbox_footer');
                    grepodataFooter.appendChild(addBtn);
                    grepodataFooter.appendChild(shareBtn)
                    footerElement.appendChild(grepodataFooter);

                    // Set footer button placement
                    var folderElement = footerElement.querySelector('#select_folder_id');
                    footerElement.style.backgroundSize = 'auto 100%';
                    footerElement.style.padding = '6px 0';
                    dateElement.style.marginTop = '-4px';
                    dateElement.style.marginLeft = '3px';
                    dateElement.style.position = 'absolute';
                    dateElement.style.zIndex = '7';
					dateElement.style.background = 'url(https://gpnl.innogamescdn.com/images/game/border/footer.png) repeat-x 0px -6px';
                    if (folderElement !== null) {
                        folderElement.style.position = 'absolute';
                        folderElement.style.marginTop = '12px';
                        folderElement.style.marginLeft = '3px';
                        folderElement.style.zIndex = '6';
                    }

                    // Handle inbox keyboard shortcuts
                    document.removeEventListener('keyup', inboxNavShortcut);
                    document.addEventListener('keyup', inboxNavShortcut);
                }

            }
        }

        function inboxNavShortcut(e) {
            var reportElement = document.getElementById("report_report");
            if (gd_settings.keys_enabled === true && !['textarea', 'input'].includes(e.srcElement.tagName.toLowerCase()) && reportElement !== null) {
                switch (e.key) {
                    case gd_settings.key_inbox_prev:
                        var prev = reportElement.getElementsByClassName('last_report game_arrow_left');
                        if (prev.length === 1 && prev[0] != null) {
                            prev[0].click();
                        }
                        break;
                    case gd_settings.key_inbox_next:
                        var next = reportElement.getElementsByClassName('next_report game_arrow_right');
                        if (next.length === 1 && next[0] != null) {
                            next[0].click();
                        }
                        break;
                    default:
                        break;
                }
            }
        }

        function addForumReportById(reportId, reportHash) {
            var reportElement = document.getElementById(reportId);

            // Find report poster
            var inspectedElement = reportElement.parentElement;
            var search_limit = 20;
            var found = false;
            var reportPoster = '_';
            while (!found && search_limit > 0 && inspectedElement !== null) {
                try {
                    var owners = inspectedElement.getElementsByClassName("bbcodes_player");
                    if (owners.length !== 0) {
                        for (var g = 0; g < owners.length; g++) {
                            if (owners[g].parentElement.classList.contains('author')) {
                                reportPoster = owners[g].innerText;
                                if (reportPoster === '') reportPoster = '_';
                                found = true;
                            }
                        }
                    }
                    inspectedElement = inspectedElement.parentElement;
                }
                catch (err) {
                }
                search_limit -= 1;
            }

            addToIndexFromForum(reportId, reportElement, reportPoster, reportHash);
        }

        // Forum reports
        function parseForumReport() {
            var reportsInView = document.getElementsByClassName("bbcodes published_report");

            //process reports
            if (reportsInView.length > 0) {
                for (var i = 0; i < reportsInView.length; i++) {
                    var reportElement = reportsInView[i];
                    var reportId = reportElement.id;

                    if (!$('#gd_index_f_' + reportId).get(0)) {

                        var bSpy = false;
                        if (reportElement.getElementsByClassName("espionage_report").length > 0) {
                            bSpy = true;
                        } else if (reportElement.getElementsByClassName("report_units").length < 2
                            || reportElement.getElementsByClassName("conquest").length > 0) {
                            // ignore non intel reports
                            continue;
                        }

                        var reportHash = null;
                        try {
                            // === Build report hash to create a unique identifier for this report that is consistent between sessions
                            // Try to parse time string
                            var header = reportElement.getElementsByClassName('published_report_header bold')[0];
                            var dateText = header.getElementsByClassName('reports_date small')[0].innerText;
                            try {
                                var time = dateText.match(time_regex);
                                if (time != null) {
                                    dateText = time[0];
                                }
                            } catch (e) {
                            }

                            // Try to parse town ids from report header
                            var headerText = header.getElementsByClassName('bold')[0].innerText;
                            try {
                                var towns = header.getElementsByClassName('gp_town_link');
                                if (towns.length === 2) {
                                    var ids = [];
                                    for (var m = 0; m < towns.length; m++) {
                                        var href = towns[m].getAttribute("href");
                                        var townJson = decodeHashToJson(href);
                                        ids.push(townJson.id);
                                    }
                                    if (ids.length === 2) {
                                        headerText = ids.join('');
                                    }
                                }
                            } catch (e) {
                            }

                            // Try to parse units and buildings
                            var reportUnits = reportElement.getElementsByClassName('unit_icon40x40');
                            var reportBuildings = reportElement.getElementsByClassName('report_unit');
                            var reportDetails = reportElement.getElementsByClassName('report_details');
                            var reportContent = '';
                            try {
                                for (var u = 0; u < reportUnits.length; u++) {
                                    reportContent += reportUnits[u].outerHTML;
                                }
                                for (var u = 0; u < reportBuildings.length; u++) {
                                    reportContent += reportBuildings[u].outerHTML;
                                }
                                if (reportDetails.length === 1) {
                                    reportContent += reportDetails[0].innerText;
                                }
                            } catch (e) {
                            }

                            // Combine intel and generate hash
                            var reportText = dateText + headerText + reportContent;
                            if (reportText !== null && reportText !== '') {
                                reportHash = reportText.report_hash();
                            }

                        } catch (err) {
                            reportHash = null;
                        }
                        console.log('Parsed forum report with hash: ' + reportHash);

                        var exists = false;
                        if (reportHash !== null && reportHash !== 0) {
                            for (var j = 0; j < globals.reportsFoundForum.length; j++) {
                                if (globals.reportsFoundForum[j] == reportHash) {
                                    exists = true;
                                }
                            }
                        }

                        var shareBtn = document.createElement('a');
                        var shareInput = document.createElement('input');
                        var rightShareSpan = document.createElement('span');
                        var leftShareSpan = document.createElement('span');
                        var txtShareSpan = document.createElement('span');
                        shareInput.setAttribute('type', 'text');
                        shareInput.setAttribute('id', 'gd_share_rep_inp');
                        shareInput.setAttribute('style', 'float: right;');
                        txtShareSpan.setAttribute('id', 'gd_share_rep_txt');
                        txtShareSpan.setAttribute('class', 'middle');
                        txtShareSpan.setAttribute('style', 'min-width: 50px;');
                        rightShareSpan.setAttribute('class', 'right');
                        leftShareSpan.setAttribute('class', 'left');
                        leftShareSpan.appendChild(rightShareSpan);
                        rightShareSpan.appendChild(txtShareSpan);
                        shareBtn.appendChild(leftShareSpan);
                        shareBtn.setAttribute('href', '#');
                        shareBtn.setAttribute('id', 'gd_share_rep_');
                        shareBtn.setAttribute('class', 'button gd_btn_share');
                        shareBtn.setAttribute('style', 'float: right;');

                        txtShareSpan.innerText = translate.SHARE;


                        shareBtn.addEventListener('click', () => {
                            if ($('#gd_share_rep_txt').get(0)) {
                                var hashI = ('r' + reportHash).replace('-', 'm');
                                var content = '<b>Share this report on Discord:</b><br><ul>' +
                                    '    <li>1. Install the GrepoData bot in your Discord server (<a href="https://grepodata.com/discord" target="_blank">link</a>).</li>' +
                                    '    <li>2. Insert the following code in your Discord server.<br/>The bot will then create the screenshot for you!' +
                                    '    </ul><br/><input type="text" class="gd-copy-input-' + reportHash + '" value="' + `!gd report ${hashI}` + '"> <a href="#" class="gd-copy-command-' + reportHash + '">Copy to clipboard</a><span class="gd-copy-done-' + reportHash + '" style="display: none; float: right;"> Copied!</span>' +
                                    '    <br /><br /><small>Thank you for using <a href="https://grepodata.com" target="_blank">GrepoData</a>!</small>';

                                Layout.wnd.Create(GPWindowMgr.TYPE_DIALOG).setContent(content);
                                addForumReportById($('#gd_index_f_' + reportId).attr('report_id'), $('#gd_index_f_' + reportId).attr('report_hash'));

                                $(".gd-copy-command-" + reportHash).click(function () {
                                    $(".gd-copy-input-" + reportHash).select();
                                    document.execCommand('copy');

                                    $('.gd-copy-done-' + reportHash).get(0).style.display = 'block';
                                    setTimeout(function () {
                                        if ($('.gd-copy-done-' + reportHash).get(0)) {
                                            $('.gd-copy-done-' + reportHash).get(0).style.display = 'none';
                                        }
                                    }, 3000);
                                });
                            }
                        })

                        if (reportHash == null) {
                            reportHash = '';
                        }
                        if (bSpy === true) {
                            $(reportElement).append('<div class="gd_indexer_footer" style="background: #fff; height: 28px; margin-top: -28px;">\n' +
                                '    <a href="#" id="gd_index_f_' + reportId + '" report_hash="' + reportHash + '" report_id="' + reportId + '" class="button rh' + reportHash + ' gd_btn_index" style="float: right;"><span class="left"><span class="right"><span id="gd_index_f_txt_' + reportId + '" class="middle" style="min-width: 50px;">' + translate.ADD + ' +</span></span></span></a>\n' +
                                '    </div>');
                            $(reportElement).find('.resources, .small').css("text-align", "left");
                        } else {
                            $(reportElement).append('<div class="gd_indexer_footer" style="background: url(https://gpnl.innogamescdn.com/images/game/border/odd.png); height: 28px; margin-top: -52px;">\n' +
                                '    <a href="#" id="gd_index_f_' + reportId + '" report_hash="' + reportHash + '" report_id="' + reportId + '" class="button rh' + reportHash + ' gd_btn_index" style="float: right;"><span class="left"><span class="right"><span id="gd_index_f_txt_' + reportId + '" class="middle" style="min-width: 50px;">' + translate.ADD + ' +</span></span></span></a>\n' +
                                '    </div>');
                            $(reportElement).find('.button, .simulator, .all').parent().css("padding-top", "24px");
                            $(reportElement).find('.button, .simulator, .all').siblings("span").css("margin-top", "-24px");
                        }

                        $(reportElement).find('.gd_indexer_footer').append(shareBtn);

                        if (exists === true) {
                            $('#gd_index_f_' + reportId).get(0).style.color = '#36cd5b';
                            $('#gd_index_f_txt_' + reportId).get(0).innerText = translate.ADDED + ' ✓';
                        } else {
                            $('#gd_index_f_' + reportId).click(function () {
                                addForumReportById($(this).attr('report_id'), $(this).attr('report_hash'));
                            });
                        }
                    }
                }
            }
        }

        function settings() {
            if (!$("#gd_indexer").get(0)) {
                $(".settings-menu ul:last").append('<li id="gd_li"><svg aria-hidden="true" data-prefix="fas" data-icon="university" class="svg-inline--fa fa-university fa-w-16" role="img" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" style="color: #2E4154;width: 16px;width: 15px;vertical-align: middle;margin-top: -2px;"><path fill="currentColor" d="M496 128v16a8 8 0 0 1-8 8h-24v12c0 6.627-5.373 12-12 12H60c-6.627 0-12-5.373-12-12v-12H24a8 8 0 0 1-8-8v-16a8 8 0 0 1 4.941-7.392l232-88a7.996 7.996 0 0 1 6.118 0l232 88A8 8 0 0 1 496 128zm-24 304H40c-13.255 0-24 10.745-24 24v16a8 8 0 0 0 8 8h464a8 8 0 0 0 8-8v-16c0-13.255-10.745-24-24-24zM96 192v192H60c-6.627 0-12 5.373-12 12v20h416v-20c0-6.627-5.373-12-12-12h-36V192h-64v192h-64V192h-64v192h-64V192H96z"></path></svg><a id="gd_indexer" href="#" style="    margin-left: 4px;">GrepoData City Indexer</a></li>');

                // Intro
                // var layoutUrl = 'https' + window.getComputedStyle(document.getElementsByClassName('icon')[0], null).background.split('("https')[1].split('"')[0];
                var settingsHtml = '<div id="gd_settings_container" style="display: none; position: absolute; top: 0; bottom: 0; right: 0; left: 232px; padding: 0px; overflow: auto;">\n' +
                    '    <div id="gd_settings" style="position: relative;">\n' +
                    '\t\t<div class="section" id="s_gd_city_indexer">\n' +
                    '\t\t\t<div class="game_header bold" style="margin: -5px -10px 15px -10px; padding-left: 10px;">GrepoData city indexer settings</div>\n' +
                    '\t\t\t<p>' + translate.ABOUT + '.' +
                    '\t\t\t' + translate.INDEX_LIST + ': ';
                globals.gdIndexScript.forEach(function (index, i) {
                    settingsHtml = settingsHtml + (i > 0 ? ', ' : '') + '<a href="https://grepodata.com/indexer/' + index + '" target="_blank">' + index + '</a>';
                });
                settingsHtml = settingsHtml + '</p>' + (count > 0 ? '<p>' + translate.COUNT_1 + count + translate.COUNT_2 + '.</p>' : '') +
                    '<p id="gd_s_saved" style="display: none; position: absolute; left: 50px; margin: 0;"><strong>' + translate.SAVED + ' ✓</strong></p> ' +
                    '<br/>\n';

                settingsHtml = settingsHtml + '<div style="max-height: '+(count > 0 ? 340 : 360)+'px; overflow-y: scroll; background: #FFEECA; border: 2px solid #d0be97;">';

                // Forum intel settings
                settingsHtml += '\t\t\t<p style="margin-bottom: 10px; margin-left: 10px;"><strong>' + translate.COLLECT_INTEL + '</strong></p>\n' +
                    '\t\t\t<div style="margin-left: 30px;" class="checkbox_new inbox_gd_enabled' + (gd_settings.inbox === true ? ' checked' : '') + '">\n' +
                    '\t\t\t\t<div class="cbx_icon"></div><div class="cbx_caption">' + translate.COLLECT_INTEL_INBOX + '</div>\n' +
                    '\t\t\t</div>\n' +
                    '\t\t\t<div style="margin-left: 30px;" class="checkbox_new forum_gd_enabled' + (gd_settings.forum === true ? ' checked' : '') + '">\n' +
                    '\t\t\t\t<div class="cbx_icon"></div><div class="cbx_caption">' + translate.COLLECT_INTEL_FORUM + '</div>\n' +
                    '\t\t\t</div>\n' +
                    '\t\t\t<br><br><hr>\n';

                // Stats link
                settingsHtml += '\t\t\t<p style="margin-left: 10px; display: inline-flex; height: 14px;"><strong>' + translate.STATS_LINK_TITLE + '</strong> <span style="background: '+gd_icon+'; width: 26px; height: 24px; margin-top: -5px; margin-left: 10px;"></span></p>\n' +
                    '\t\t\t<div style="margin-left: 30px;" class="checkbox_new stats_gd_enabled' + (gd_settings.stats === true ? ' checked' : '') + '">\n' +
                    '\t\t\t\t<div class="cbx_icon"></div><div class="cbx_caption">' + translate.STATS_LINK + '</div>\n' +
                    '\t\t\t</div>\n' +
                    '\t\t\t<br><br><hr>\n';

                // Command overview
                settingsHtml += '\t\t\t<p style="margin-bottom: 10px; margin-left: 10px;"><strong>' + translate.CMD_OVERVIEW_TITLE + '</strong></p>\n' +
                    '\t\t\t<div style="margin-left: 30px;" class="checkbox_new cmdoverview_gd_enabled' + (gd_settings.cmdoverview === true ? ' checked' : '') + '">\n' +
                    '\t\t\t\t<div class="cbx_icon"></div><div class="cbx_caption">' + translate.CMD_OVERVIEW_INFO + '</div>\n' +
                    '\t\t\t</div>\n' +
                    '\t\t\t<br><br><hr>\n';

                // Context menu
                settingsHtml += '\t\t\t<p style="margin-left: 10px; display: inline-flex; height: 14px;"><strong>' + translate.CONTEXT_TITLE + '</strong> <span style="background: '+gd_icon_intel+'; width: 50px; height: 50px; transform: scale(0.6); margin-top: -18px;"></span></p>\n' +
                    '\t\t\t<div style="margin-left: 30px;" class="checkbox_new context_gd_enabled' + (gd_settings.cmdoverview === true ? ' checked' : '') + '">\n' +
                    '\t\t\t\t<div class="cbx_icon"></div><div class="cbx_caption">' + translate.CONTEXT_INFO + '</div>\n' +
                    '\t\t\t</div>\n' +
                    '\t\t\t<br><br><hr>\n';

                // Keyboard shortcut settings
                settingsHtml += '\t\t\t<p style="margin-bottom: 10px; margin-left: 10px;"><strong>' + translate.SHORTCUTS + '</strong></p>\n' +
                    '\t\t\t<div style="margin-left: 30px;" class="checkbox_new keys_enabled_gd_enabled' + (gd_settings.keys_enabled === true ? ' checked' : '') + '">\n' +
                    '\t\t\t\t<div class="cbx_icon"></div><div class="cbx_caption">' + translate.SHORTCUTS_ENABLED + '</div>\n' +
                    '\t\t\t</div><br/><br/>\n' +
                    '\t\t\t<div class="gd_shortcut_settings" style="margin-left: 45px; margin-right: 20px; border: 1px solid black;"><table style="width: 100%;">\n' +
                    '\t\t\t\t<tr><th style="width: 50%;">' + translate.SHORTCUT_FUNCTION + '</th><th>Shortcut</th></tr>\n' +
                    '\t\t\t\t<tr><td>' + translate.SHORTCUTS_INBOX_PREV + '</td><td>' + gd_settings.key_inbox_prev + '</td></tr>\n' +
                    '\t\t\t\t<tr><td>' + translate.SHORTCUTS_INBOX_NEXT + '</td><td>' + gd_settings.key_inbox_next + '</td></tr>\n' +
                    '\t\t\t</table></div>\n' +
                    '\t\t\t<br/>';

                // Footer
                settingsHtml += '</div>' +
					'<a href="https://grepodata.com/message" target="_blank">Contact us</a>' +
                    '<p style="font-style: italic; font-size: 10px; float: right; margin:0px;">GrepoData city indexer v' + gd_version + ' [<a href="https://api.grepodata.com/userscript/cityindexer_' + index_hash + '.user.js" target="_blank">' + translate.CHECK_UPDATE + '</a>]</p>' +
                    '\t\t</div>\n' +
                    '    </div>\n' +
                    '</div>';

                // Insert settings menu
                $(".settings-menu").parent().append(settingsHtml);

                // Handle settings events
                $(".settings-link").click(function () {
                    $('#gd_settings_container').get(0).style.display = "none";
                    $('.settings-container').get(0).style.display = "block";
                    gdsettings = false;
                });

                $("#gd_indexer").click(function () {
                    $('.settings-container').get(0).style.display = "none";
                    $('#gd_settings_container').get(0).style.display = "block";
                });

                $(".inbox_gd_enabled").click(function () {
                    settingsCbx('inbox', !gd_settings.inbox);
                    if (!gd_settings.inbox) {
                        settingsCbx('keys_enabled', false);
                    }
                });
                $(".forum_gd_enabled").click(function () {
                    settingsCbx('forum', !gd_settings.forum);
                });
                $(".stats_gd_enabled").click(function () {
                    settingsCbx('stats', !gd_settings.stats);
                });
                $(".cmdoverview_gd_enabled").click(function () {
                    settingsCbx('cmdoverview', !gd_settings.cmdoverview);
                });
                $(".context_gd_enabled").click(function () {
                    settingsCbx('context', !gd_settings.context);
                });
                $(".keys_enabled_gd_enabled").click(function () {
                    settingsCbx('keys_enabled', !gd_settings.keys_enabled);
                });

                if (gdsettings === true) {
                    $('.settings-container').get(0).style.display = "none";
                    $('#gd_settings_container').get(0).style.display = "block";
                }
            }
        }

        function settingsCbx(type, value) {
            // Update class
            if (value === true) {
                $('.' + type + '_gd_enabled').get(0).classList.add("checked");
            }
            else {
                $('.' + type + '_gd_enabled').get(0).classList.remove("checked");
            }
            // Set value
            gd_settings[type] = value;
            saveSettings();
            $('#gd_s_saved').get(0).style.display = 'block';
            setTimeout(function () {
                if ($('#gd_s_saved').get(0)) {
                    $('#gd_s_saved').get(0).style.display = 'none';
                }
            }, 3000);
        }

        function saveSettings() {
            localStorage.setItem('gd_city_indexer_s', JSON.stringify(gd_settings));
        }

        var townIntelHistory = {}

        // Save town intel to local storage
        function saveIntelHistory() {
            var max_items_in_memory = 100;

            // Convert to list
            var items = Object.keys(townIntelHistory).map(function(key) {
                return [key, townIntelHistory[key]];
            });

            // Order by time added desc
            items.sort(function(first, second) {
                return second[1].t - first[1].t;
            });

            // Slice & save
            items = items.slice(0, max_items_in_memory);
            localStorage.setItem('gd_city_indexer_i', JSON.stringify(items));
        }

        // Load local town intel history
        function readIntelHistory() {
            var intelJson = localStorage.getItem('gd_city_indexer_i');
            if (intelJson != null) {
                result = JSON.parse(intelJson);
                var items = {}
                result.forEach(function(e) {items[e[0]] = e[1]})
                console.log("Loaded town intel from local storage: ", items);
                townIntelHistory = items;
            }
        }

        function addToTownHistory(id, units) {
            var stamp = new Date().getTime();
            townIntelHistory[id] = {u: units, t: stamp};
            if (gd_settings.cmdoverview === true) {
                saveIntelHistory();
            }
        }

        var openIntelWindows = {};
        function loadTownIntel(id, town_name, player_name, cmd_id=0) {
            try {
				// Create a new dialog
                var content_id = player_name + id;
                content_id = content_id.split(' ').join('_');
                if (openIntelWindows[content_id]) {
                    try {
                        openIntelWindows[content_id].close();
                    } catch (e) {console.log("unable to close window", e);}
                }
				var intelUrl = 'https://grepodata.com/indexer/town/'+index_key+'/'+world+'/'+id;
                var intel_window = Layout.wnd.Create(GPWindowMgr.TYPE_DIALOG,
                    '<a target="_blank" href="'+intelUrl+'" class="write_message" style="background: ' + gd_icon + '"></a>&nbsp;&nbsp;' + translate.TOWN_INTEL + ': ' + town_name + (player_name!=''?(' (' + player_name + ')'):''),
                    {position: ["center", 110], minimizable: true});
                intel_window.setWidth(600);
                intel_window.setHeight(590);
                openIntelWindows[content_id] = intel_window;

                // Window content
                var content = '<div class="gdintel_'+content_id+'" style="width: 600px; height: 500px;"><div style="text-align: center">' +
					'<p style="font-size: 20px; padding-top: 180px;">Loading intel..</p>' +
					'<a style="font-size: 11px;" href="' + intelUrl + '" target="_blank">' + intelUrl + '</a>' +
					'</div></div>';
                intel_window.setContent(content);
				var intelWindowElement = $('.gdintel_'+content_id).parent();
				$(intelWindowElement).css({ top: 43 });

				// Get town intel from backend
                $.ajax({
                    method: "get",
                    url: "https://api.grepodata.com/indexer/api/town?keys=" + getActiveIndexes() + "&id=" + id
                }).error(function (err) {
					console.error(err);
					renderTownIntelError(content_id, intelUrl);
                }).done(function (response) {
					renderTownIntelWindow(response, id, town_name, player_name, cmd_id, content_id);
                });
            } catch (err) {
                console.error(err);
				renderTownIntelError(content_id, intelUrl);
            }
        }

		function renderTownIntelError(content_id, intelUrl) {
			$('.gdintel_'+content_id).empty();
			$('.gdintel_'+content_id).append('<div style="text-align: center">' +
											 '<p style="padding-top: 100px;">Sorry, no intel available at the moment.<br/>Please <a href="https://grepodata.com/message" target="_blank" style="">contact us</a> if this error persists.</p>' +
											 '<p style="padding-top: 50px;">Alternatively, you can view this town\'s intel on grepodata.com:<br/>' +
											 '<a href="' + intelUrl + '" target="_blank" style="">' + intelUrl + '</a></p></div>');
		}

		function renderTownIntelWindow(data, id, town_name, player_name, cmd_id, content_id) {
			try {
				var unitHeight = 255;
				var notesHeight = 170;

				if (data.intel==null || data.intel.length <= 3) {
					unitHeight = 150;
					notesHeight = 275;
					addToTownHistory(id, []);
				}

				// Intel content
				var tooltips = [];
				$('.gdintel_'+content_id).empty();

				// Title
				var townHash = getTownHash(parseInt(id), town_name, data.ix, data.iy);
				var playerHash = getPlayerHash(data.player_id, data.player_name);
				var title = '<div style="margin-bottom: 10px;">Town intelligence for: ' +
					'<a href="#'+townHash+'" class="gp_town_link"><img alt="" src="/images/game/icons/town.png" style="padding-right: 2px; vertical-align: top;">'+ data.name +'</a> ' +
					'(<a href="#'+playerHash+'" class="gp_player_link"> <img alt="" src="/images/game/icons/player.png" style="padding-right: 2px; vertical-align: top;">'+ data.player_name +'</a>)' +
					'<a href="https://grepodata.com/indexer/' + index_key + '" class="gd-ext-ref" target="_blank" style="float: right;">Index: ' + index_key + '</a></div>';
				$('.gdintel_'+content_id).append(title);

				// Version check
				if (data.hasOwnProperty('latest_version') && data.latest_version != null && data.latest_version.toString() !== gd_version) {
					var updateHtml =
						'<div class="gd-update-available" style=" background: #b93b3b; color: #fff; text-align: center; border-radius: 10px; padding-bottom: 2px;">' +
						'New userscript version available: ' +
						'<a href="https://api.grepodata.com/userscript/cityindexer_' + index_hash + '.user.js" class="gd-ext-ref" target="_blank" ' +
						'style="color: #ffffff; text-decoration: underline;">Update now!</a></div>';
					$('.gdintel_'+content_id).append(updateHtml);
					$('.gd-update-available').tooltip((data.hasOwnProperty('update_message') ? data.update_message : data.latest_version));
					unitHeight -= 18;
				}

				// Buildings
				var build = '<div class="gd_build_' + id + '" style="padding-bottom: 4px;">';
				var date = '';
				var hasBuildings = false;
				for (var j = 0; j < Object.keys(data.buildings).length; j++) {
					var name = Object.keys(data.buildings)[j];
					var value = data.buildings[name].level.toString();
					if (value != null && value != '' && value.indexOf('%') < 0) {
						date = data.buildings[name].date;
						build = build + '<div class="building_header building_icon40x40 ' + name + ' regular" id="icon_building_' + name + '" ' +
							'style="margin-left: 3px; width: 32px; height: 32px;">' +
							'<div style="position: absolute; top: 17px; margin-left: 8px; z-index: 10; color: #fff; font-size: 12px; font-weight: 700; text-shadow: 1px 1px 3px #000;">' + value + '</div>' +
							'</div>';
					}
					if (name != 'wall') {
						hasBuildings = true;
					}
				}
				build = build + '</div>';
				if (hasBuildings == true) {
					$('.gdintel_'+content_id).append(build);
					$('.gd_build_' + id).tooltip('Buildings as of: ' + date);
					unitHeight -= 40;
				}

				// Units table
				var table =
					'<div class="game_border" style="max-height: 100%;">\n' +
					'   <div class="game_border_top"></div><div class="game_border_bottom"></div><div class="game_border_left"></div><div class="game_border_right"></div>\n' +
					'   <div class="game_border_corner corner1"></div><div class="game_border_corner corner2"></div><div class="game_border_corner corner3"></div><div class="game_border_corner corner4"></div>\n' +
					'   <div class="game_header bold">\n' +
					'Unit intelligence\n' +
					'   </div>\n' +
					'   <div style="height: '+unitHeight+'px;">' +
					'     <ul class="game_list" style="display: block; width: 100%; height: '+unitHeight+'px; overflow-x: hidden; overflow-y: auto;">\n';
				var bHasIntel = false;
				var maxCost = 0;
				var maxCostUnits = [];
				for (var j = 0; j < Object.keys(data.intel).length; j++) {
					var intel = data.intel[j];
					var row = '';

					// Check intel value
					if (intel.cost && intel.cost > maxCost) {
						maxCost = intel.cost;
						maxCostUnits = intel.units;
					}

					// Type
					if (intel.type != null && intel.type != '') {
						bHasIntel = true;
						var typeUrl = '';
						var tooltip = '';
						var flip = true;
						switch (intel.type) {
							case 'enemy_attack':
								typeUrl = '/images/game/towninfo/attack.png';
								tooltip = 'Enemy attack';
								break;
							case 'friendly_attack':
								flip = false;
								typeUrl = '/images/game/towninfo/attack.png';
								tooltip = 'Friendly attack';
								break;
							case 'attack_on_conquest':
								typeUrl = '/images/game/towninfo/conquer.png';
								tooltip = 'Attack on conquest';
								break;
							case 'support':
								typeUrl = '/images/game/towninfo/support.png';
								tooltip = 'Sent in support';
								break;
							case 'spy':
								typeUrl = '/images/game/towninfo/espionage_2.67.png';
								if (intel.silver != null && intel.silver != '') {
									tooltip = 'Silver used: ' + intel.silver;
								}
								break;
							default:
								typeUrl = '/images/game/towninfo/attack.png';
						}
						var typeHtml =
							'<div style="position: absolute; height: 0px; margin-top: -5px; ' +
							(flip ? '-moz-transform: scaleX(-1); -o-transform: scaleX(-1); -webkit-transform: scaleX(-1); transform: scaleX(-1); filter: FlipH; -ms-filter: "FlipH";' : '') +
							'"><div style="background: url(' + typeUrl + ');\n' +
							'    padding: 0;\n' +
							'    height: 50px;\n' +
							'    width: 50px;\n' +
							'    position: relative;\n' +
							'    display: inherit;\n' +
							'    transform: scale(0.6, 0.6);-ms-transform: scale(0.6, 0.6);-webkit-transform: scale(0.6, 0.6);' +
							'    box-shadow: 0px 0px 9px 0px #525252;" class="intel-type-' + id + '-' + j + '"></div></div>';
						row = row +
							'<div style="display: table-cell; width: 50px;">' +
							typeHtml +
							'</div>';
						tooltips.push(tooltip);
					} else {
						row = row + '<div style="display: table-cell;"></div>';
					}

					// Date
					row = row + '<div style="display: table-cell; width: 100px;" class="bold"><div style="margin-top: 3px; position: absolute;">' + intel.date.replace(' ', '<br/>') + '</div></div>';

					// units
					var unitHtml = '';
					var killed = false;
					for (var i = 0; i < Object.keys(intel.units).length; i++) {
						var unit = intel.units[i];
						var size = 10;
						switch (Math.max(unit.count.toString().length, unit.killed.toString().length)) {
							case 1:
							case 2:
								size = 11;
								break;
							case 3:
								size = 10;
								break;
							case 4:
								size = 8;
								break;
							case 5:
								size = 6;
								break;
							default:
								size = 10;
						}
						if (unit.killed > 0) {
							killed = true;
						}
						unitHtml = unitHtml +
							'<div class="unit_icon25x25 ' + unit.name + '" style="overflow: unset; font-size: ' + size + 'px; text-shadow: 1px 1px 3px #000; color: #fff; font-weight: 700; border: 1px solid #626262; padding: 10px 0 0 0; line-height: 13px; height: 15px; text-align: right; margin-right: 2px;">' +
							unit.count +
							(unit.killed > 0 ? '   <div class="report_losts" style="position: absolute; margin: 4px 0 0 0; font-size: ' + (size - 1) + 'px; text-shadow: none;">-' + unit.killed + '</div>\n' : '') +
							'</div>';
					}
					if (intel.hero != null) {
						unitHtml = unitHtml +
							'<div class="hero_icon_border golden_border" style="display: inline-block;">\n' +
							'    <div class="hero_icon_background">\n' +
							'        <div class="hero_icon hero25x25 ' + intel.hero.toLowerCase() + '"></div>\n' +
							'    </div>\n' +
							'</div>';
					}
					row = row + '<div style="display: table-cell;"><div><div class="origin_town_units" style="padding-left: 30px; margin: 5px 0 5px 0; ' + (killed ? 'height: 37px;' : '') + '">' + unitHtml + '</div></div></div>';

					// Wall
					if (intel.wall !== null && intel.wall !== '' && (!isNaN(0) || intel.wall.indexOf('%') < 0)) {
						row = row +
							'<div style="display: table-cell; width: 50px; float: right;">' +
							'<div class="sprite-image" style="display: block; font-weight: 600; ' + (killed ? '' : 'padding-top: 10px;') + '">' +
							'<div style="position: absolute; top: 19px; margin-left: 8px; z-index: 10; color: #fff; font-size: 10px; text-shadow: 1px 1px 3px #000;">' + intel.wall + '</div>' +
							'<img src="https://gpnl.innogamescdn.com/images/game/main/buildings_sprite_40x40.png" alt="icon" ' +
							'width="40" height="40" style="object-fit: none;object-position: -40px -80px;width: 40px;height: 40px;' +
							'transform: scale(0.68, 0.68);-ms-transform: scale(0.68, 0.68);-webkit-transform: scale(0.68, 0.68);' +
							'padding-left: -7px; margin: -48px 0 0 0px; position:absolute;">' +
							'</div></div>';
					} else {
						row = row + '<div style="display: table-cell;"></div>';
					}

					var rowHeader = '<li class="' + (j % 2 === 0 ? 'odd' : 'even') + '" style="display: inherit; width: 100%; padding: 0 0 ' + (killed ? '0' : '4px') + ' 0;">';
					table = table + rowHeader + row + '</li>\n';
				}
				addToTownHistory(id, maxCostUnits);

				if (bHasIntel == false) {
					table = table + '<li class="even" style="display: inherit; width: 100%;"><div style="text-align: center;">' +
						'<strong>No unit intellgence available</strong><br/>' +
						'You have not yet indexed any reports about this town.<br/><br/>' +
						'<span style="font-style: italic;">note: intel about your allies (index contributors) is hidden by default</span></div></li>\n';
				}

				table = table + '</ul></div></div>';
				$('.gdintel_'+content_id).append(table);
				for (var j = 0; j < tooltips.length; j++) {
					$('.intel-type-' + id + '-' + j).tooltip(tooltips[j]);
				}

				// notes
				var notesHtml =
					'<div class="game_border" style="max-height: 100%; margin-top: 10px;">\n' +
					'   <div class="game_border_top"></div><div class="game_border_bottom"></div><div class="game_border_left"></div><div class="game_border_right"></div>\n' +
					'   <div class="game_border_corner corner1"></div><div class="game_border_corner corner2"></div><div class="game_border_corner corner3"></div><div class="game_border_corner corner4"></div>\n' +
					'   <div class="game_header bold">\n' +
					'Notes\n' +
					'   </div>\n' +
					'   <div style="height: '+notesHeight+'px;">' +
					'     <ul class="game_list" style="display: block; width: 100%; height: '+notesHeight+'px; overflow-x: hidden; overflow-y: auto;">\n';
				notesHtml = notesHtml + '<li class="even" style="display: flex; justify-content: space-around; align-items: center;" id="gd_new_note_'+content_id+'">' +
					'<div style=""><strong>Add note: </strong><img alt="" src="/images/game/icons/player.png" style="vertical-align: top; padding-right: 2px;">'+Game.player_name+'</div>' +
					'<div style="width: '+(60 - Game.player_name.length)+'%;"><input id="gd_note_input_'+content_id+'" type="text" placeholder="Add a note about this town" style="width: 100%;"></div>' +
					'<div style=""><div id="gd_adding_note_'+content_id+'" style="display: none;">Saving..</div><div id="gd_add_note_'+content_id+'" gd-town-id="'+id+'" class="button_new" style="top: -1px;"><div class="left"></div><div class="right"></div><div class="caption js-caption">Add<div class="effect js-effect"></div></div></div></div>' +
					'</li>\n';
				var bHasNotes = false;
				for (var j = 0; j < Object.keys(data.notes).length; j++) {
					var note = data.notes[j];
					bHasNotes = true;
					notesHtml = notesHtml + getNoteRowHtml(note, content_id, j);
				}

				if (bHasNotes == false) {
					notesHtml = notesHtml + '<li class="odd" style="display: inherit; width: 100%;"><div style="text-align: center;">' +
						'There are no notes for this town' +
						'</div></li>\n';
				}

				notesHtml = notesHtml + '</ul></div></div>';
				$('.gdintel_'+content_id).append(notesHtml);

				// Add note
				$('#gd_add_note_'+content_id).click(function () {
					var town_id = $('#gd_add_note_'+content_id).attr('gd-town-id');
					var note = $('#gd_note_input_'+content_id).val().split('<').join(' ').split('>').join(' ').split('#').join(' ');
					if (note != '') {
						$('.gd_note_error_msg').hide();
						if (note.length > 500) {
							$('#gd_new_note_'+content_id).after('<li class="even gd_note_error_msg" style="display: inherit; width: 100%;">'+
																'<div style="text-align: center;"><strong>Note is too long.</strong> A note can have a maximum of 500 characters.</div>' +
																'</li>\n');
						} else {
							$('#gd_add_note_'+content_id).hide();
							$('#gd_adding_note_'+content_id).show();
							$('#gd_note_input_'+content_id).prop('disabled',true);
							saveNewNote(town_id, note, content_id);
						}
					}
				});

				// Del note
				$('.gd_del_note_'+content_id).click(function () {
					var note_id = $(this).attr('gd-note-id');
					$(this).hide();
					$(this).after('<p style="margin: 0;">Note deleted</p>');
					$('#gd_note_'+content_id+'_'+note_id).css({ opacity: 0.4 });
					saveDelNote(note_id);
				});

				var world = Game.world_id;
				var exthtml =
					'<div style="display: list-item" class="gd-ext-ref">' +
					(data.player_id != null && data.player_id != 0 ? '   <a href="https://grepodata.com/indexer/player/' + index_key + '/' + world + '/' + data.player_id + '" target="_blank" style="float: left;"><img alt="" src="/images/game/icons/player.png" style="float: left; padding-right: 2px;">Show player intel (' + data.player_name + ')</a>' : '') +
					(data.alliance_id != null && data.alliance_id != 0 ? '   <a href="https://grepodata.com/indexer/alliance/' + index_key + '/' + world + '/' + data.alliance_id + '" target="_blank" style="float: right;"><img alt="" src="/images/game/icons/ally.png" style="float: left; padding-right: 2px;">Show alliance intel</a>' : '') +
					'</div>';
				$('.gdintel_'+content_id).append(exthtml);
				$('.gd-ext-ref').tooltip('Opens in new tab');

				if (cmd_id != 0) {
					setTimeout(function(){enhanceCommand(cmd_id, true)}, 10);
				}
			} catch (u) {
				console.error("Error rendering town intel", u);
				$('.gdintel_'+content_id).empty();
				$('.gdintel_'+content_id).append('<div style="text-align: center"><br/><br/>' +
												 'No intel available at the moment.<br/>Index some new reports about this town to collect intel.<br/><br/>' +
												 '<a href="https://grepodata.com/indexer/' + index_key + '" target="_blank" style="">Index homepage: ' + index_key + '</a></div>');
			}
		}

		function getNoteRowHtml(note, content_id, i=0) {
			var row = '<li id="gd_note_'+content_id+'_'+note.note_id+'" class="' + (i % 2 === 0 ? 'odd' : 'even') + '" style="display: inherit; width: 100%; padding: 0;">';
			row = row + '<div style="display: table-cell; padding: 0 7px; width: 200px;">' +
				(note.poster_id > 0 ? '<a href="#'+getPlayerHash(note.poster_id, note.poster_name)+'" class="gp_player_link">': '') +
				'<img alt="" src="/images/game/icons/player.png" style="padding-right: 2px; vertical-align: top;">' +
				note.poster_name+(note.poster_id > 0 ?'</a>':'')+'<br/>'+note.date+
				'</div>';
			row = row + '<div style="display: table-cell; padding: 0 7px; width: 300px; vertical-align: middle;"><strong>'+note.message+'</strong></div>';

			if (Game.player_name == note.poster_name) {
				row = row + '<div style="display: table-cell; float: right; margin-top: -25px; margin-right: 5px;"><a id="gd_del_note_'+content_id+'_'+note.note_id+'" class="gd_del_note_'+content_id+'" gd-note-id="'+note.note_id+'" style="float: right;">Delete</a></div>';
			} else {
				row = row + '<div style="display:"></div>';
			}

			row = row + '</li>\n';
			return row;
		}

        function saveNewNote(town_id, note, content_id) {
            try {
                $.ajax({
                    method: "get",
                    url: "https://api.grepodata.com/indexer/addnote?keys=" + getActiveIndexes() + "&town_id=" + town_id + "&message=" + note + "&poster_name=" + Game.player_name + "&poster_id=" + Game.player_id
                }).error(function (err) {
                    console.log("Error saving note: ", err);
                    $('#gd_new_note_'+content_id).after('<li class="even gd_note_error_msg" style="display: inherit; width: 100%;">'+
                        '<div style="display: table-cell; padding: 0 7px;"><strong>Error saving note.</strong> please try again later or contact us if this error persists.</div>' +
                        '</li>\n');
                    $('#gd_add_note_'+content_id).show();
                    $('#gd_adding_note_'+content_id).hide();
                    $('#gd_note_input_'+content_id).prop('disabled',false);
                }).done(function (response) {
					if (response.note) {
						$('#gd_new_note_'+content_id).after(getNoteRowHtml(response.note, content_id));
						$('#gd_note_input_'+content_id).val('');
                        $('#gd_del_note_'+content_id+'_'+response.note.note_id).click(function () {
                            var note_id = $(this).attr('gd-note-id');
                            $(this).hide();
                            $(this).after('<p style="margin: 0;">Note deleted</p>');
							$('#gd_note_'+content_id+'_'+note_id).css({ opacity: 0.4 });
                            saveDelNote(note_id);
                        });
					}
                    $('#gd_add_note_'+content_id).show();
                    $('#gd_adding_note_'+content_id).hide();
                    $('#gd_note_input_'+content_id).prop('disabled',false);
                });
            } catch (e) {
                console.error(e);
            }
        }

        function saveDelNote(note_id) {
            try {
                indexes = [index_key];
                if (globals.gdIndexScript.length > 1) {
                    indexes = globals.gdIndexScript;
                }
                indexes = JSON.stringify(indexes);

                $.ajax({
                    method: "get",
                    url: "https://api.grepodata.com/indexer/delnote?keys=" + indexes + "&note_id=" + note_id + "&poster_name=" + Game.player_name
                }).error(function (err) {
                    console.log("Error deleting note: ", err);
                }).done(function (b) {
                    console.log("Note deleted: ", b);
                });
            } catch (e) {
                console.error(e);
            }
        }

        function linkToStats(action, opt) {
            if (gd_settings.stats === true && opt && 'url' in opt) {
                try {
                    var url = decodeURIComponent(opt.url);
                    var json = url.match(/&json={.*}&/g)[0];
                    json = json.substring(6, json.length - 1);
                    json = JSON.parse(json);
                    if ('player_id' in json && action.search("/player") >= 0) {
                        // Add stats button to player profile
                        var player_id = json.player_id;
                        var statsBtn = '<a target="_blank" href="https://grepodata.com/player/' + gd_w.Game.world_id + '/' + player_id + '" class="write_message" style="background: ' + gd_icon + '"></a>';
                        $('#player_buttons').filter(':first').append(statsBtn);
                    } else if ('alliance_id' in json && action.search("/alliance") >= 0) {
                        // Add stats button to alliance profile
                        var alliance_id = json.alliance_id;
                        var statsBtn = '<a target="_blank" href="https://grepodata.com/alliance/' + gd_w.Game.world_id + '/' + alliance_id + '" class="write_message" style="background: ' + gd_icon + '; margin: 5px;"></a>';
                        $('#player_info > ul > li').filter(':first').append(statsBtn);
                    }
                } catch (e) {
                }
            }
        }

        var count = 0;

        function gd_indicator() {
            count = count + 1;
            $('#gd_index_indicator').get(0).innerText = count;
            $('#gd_index_indicator').get(0).style.display = 'inline';
            $('.gd_settings_icon').tooltip('Indexed Reports: ' + count);
        }

        function viewTownIntel(xhr) {
            var town_id = xhr.responseText.match(/\[town\].*?(?=\[)/g)[0];
            town_id = town_id.substring(6);

            // Add intel button and handle click event
            var intelBtn = '<div id="gd_index_town_' + town_id + '" town_id="' + town_id + '" class="button_new gdtv' + town_id + '" style="float: right; bottom: 5px;">' +
                '<div class="left"></div>' +
                '<div class="right"></div>' +
                '<div class="caption js-caption">' + translate.VIEW + '<div class="effect js-effect"></div></div></div>';
            $('.info_tab_content_' + town_id + ' > .game_inner_box > .game_border > ul.game_list > li.odd').filter(':first').append(intelBtn);

            if (gd_settings.stats === true) {
                try {
                    // Add stats button to player name
                    var player_id = xhr.responseText.match(/player_id = [0-9]*,/g);
                    if (player_id != null && player_id.length > 0) {
                        player_id = player_id[0].substring(12, player_id[0].search(','));
                        var statsBtn = '<a target="_blank" href="https://grepodata.com/player/' + gd_w.Game.world_id + '/' + player_id + '" class="write_message" style="background: ' + gd_icon + '"></a>';
                        $('.info_tab_content_' + town_id + ' > .game_inner_box > .game_border > ul.game_list > li.even > div.list_item_right').eq(1).append(statsBtn);
                        $('.info_tab_content_' + town_id + ' > .game_inner_box > .game_border > ul.game_list > li.even > div.list_item_right').css("min-width", "140px");
                    }
                    // Add stats button to ally name
                    var ally_id = xhr.responseText.match(/alliance_id = parseInt\([0-9]*, 10\),/g);
                    if (ally_id != null && ally_id.length > 0) {
                        ally_id = ally_id[0].substring(23, ally_id[0].search(','));
                        var statsBtn2 = '<a target="_blank" href="https://grepodata.com/alliance/' + gd_w.Game.world_id + '/' + ally_id + '" class="write_message" style="background: ' + gd_icon + '"></a>';
                        $('.info_tab_content_' + town_id + ' > .game_inner_box > .game_border > ul.game_list > li.odd > div.list_item_right').filter(':first').append(statsBtn2);
                        $('.info_tab_content_' + town_id + ' > .game_inner_box > .game_border > ul.game_list > li.odd > div.list_item_right').filter(':first').css("min-width", "140px");
                    }
                } catch (e) {
                    console.log(e);
                }
            }

            // Handle click:  view intel
            $('#gd_index_town_' + town_id).click(function () {
                var town_name = town_id;
                var player_name = '';
                try {
                    panel_root = $('.info_tab_content_' + town_id).parent().parent().parent().get(0);
                    town_name = panel_root.getElementsByClassName('ui-dialog-title')[0].innerText;
                    player_name = panel_root.getElementsByClassName('gp_player_link')[0].innerText;
                } catch (e) {
                    console.log(e);
                }
                //panel_root.getElementsByClassName('active')[0].classList.remove('active');
                loadTownIntel(town_id, town_name, player_name);
            });
        }

        // Loads a list of report ids that have already been added. This is used to avoid duplicates
        function loadIndexHashlist(extendMode) {
            try {
                $.ajax({
                    method: "get",
                    url: "https://api.grepodata.com/indexer/getlatest?key=" + index_key + "&player_id=" + Game.player_id + "&filter=" + JSON.stringify(gd_settings)
                }).done(function (b) {
                    try {
                        if (globals.reportsFoundForum === undefined) {
                            globals.reportsFoundForum = [];
                        }
                        if (globals.reportsFoundInbox === undefined) {
                            globals.reportsFoundInbox = [];
                        }

                        if (extendMode === false) {
                            if (b['i'] !== undefined) {
                                $.each(b['i'], function (b, d) {
                                    globals.reportsFoundInbox.push(d)
                                });
                            }
                            if (b['f'] !== undefined) {
                                $.each(b['f'], function (b, d) {
                                    globals.reportsFoundForum.push(d)
                                });
                            }
                        } else {
                            // Running in extend mode, merge with existing list
                            if (b['f'] !== undefined) {
                                globals.reportsFoundForum = globals.reportsFoundForum.filter(value => -1 !== b['f'].indexOf(value));
                            }
                            if (b['i'] !== undefined) {
                                globals.reportsFoundInbox = globals.reportsFoundInbox.filter(value => -1 !== b['i'].indexOf(value));
                            }
                        }
                    } catch (u) {}
                });
            } catch (w) {
            }
        }

		function getActiveIndexes() {
			indexes = [index_key];
			if (globals.gdIndexScript.length > 1) {
				indexes = globals.gdIndexScript;
			}
			indexes = JSON.stringify(indexes);
			return indexes;
		}
    }

    function enableCityIndex(key, globals) {
        // if (gd_w.)
        if (globals.gdIndexScript === undefined) {
            globals.gdIndexScript = [key];

            console.log('GrepoData city indexer ' + key + ' is running in primary mode.');
            loadCityIndex(key, globals);
        } else {
            globals.gdIndexScript.push(key);
            console.log('duplicate indexer script. index ' + key + ' is running in extended mode.');

            // Merge id lists
            setTimeout(function () {
                try {
                    $.ajax({
                        method: "get",
                        url: "https://api.grepodata.com/indexer/getlatest?key=" + key + "&player_id=" + gd_w.Game.player_id
                    }).done(function (b) {
                        try {
                            if (globals.reportsFoundForum === undefined) {
                                globals.reportsFoundForum = [];
                            }
                            if (globals.reportsFoundInbox === undefined) {
                                globals.reportsFoundInbox = [];
                            }

                            // Running in extend mode, merge with existing list
                            if (b['f'] !== undefined) {
                                globals.reportsFoundForum = globals.reportsFoundForum.filter(value => -1 !== b['f'].indexOf(value));
                            }
                            if (b['i'] !== undefined) {
                                globals.reportsFoundInbox = globals.reportsFoundInbox.filter(value => -1 !== b['i'].indexOf(value));
                            }
                        } catch (u) {
                            console.log(u);
                        }
                    });
                } catch (w) {
                    console.log(w);
                }
            }, 4000 * (globals.gdIndexScript.length - 1));
        }
    }

    var gd_w = window;
    if(gd_w.location.href.indexOf("grepodata.com") >= 0){
        // Viewer (grepodata.com)
        console.log("initiated grepodata.com viewer");
        grepodataObserver('');

        // Watch for angular app route change
        function grepodataObserver(path) {
            var initWatcher = setInterval(function () {
                if (gd_w.location.pathname.indexOf("/indexer/") >= 0 &&
                    gd_w.location.pathname.indexOf(index_key) >= 0 &&
                    gd_w.location.pathname != path) {
                    clearInterval(initWatcher);
                    messageObserver();
                } else if (path != "" && gd_w.location.pathname != path) {
                    path = '';
                }
            }, 300);
        }

        // Hide install message on grepodata.com/indexer
        function messageObserver() {
            var timeout = 20000;
            var initWatcher = setInterval(function () {
                timeout = timeout - 100;
                if ($('#help_by_contributing').get(0)) {
                    clearInterval(initWatcher);
                    // Hide install banner if script is already running
                    $('#help_by_contributing').get(0).style.display = 'none';
                    if ($('#new_index_install_tips').get(0) && $('#new_index_waiting').get(0)) {
                        $('#new_index_waiting').get(0).style.display = 'block';
                        $('#new_index_install_tips').get(0).style.display = 'none';
                    }
                    if ($('#userscript_version').get(0)) {
                        $('#userscript_version').append('<div id="gd_version">' + gd_version + '</div>');
                    }
                    grepodataObserver(gd_w.location.pathname);
                } else if (timeout <= 0) {
                    clearInterval(initWatcher);
                    grepodataObserver(gd_w.location.pathname);
                }
            }, 100);
        }
    } else if((gd_w.location.pathname.indexOf("game") >= 0)){
        // Indexer (in-game)
        if (gd_w['gd'+world] === undefined) gd_w['gd'+world] = {};
        enableCityIndex(index_key, gd_w['gd'+world]);
    }
} catch(error) { console.error("GrepoData City Indexer crashed (please report a screenshot of this error to admin@grepodata.com): ", error); }
})();

{/literal}