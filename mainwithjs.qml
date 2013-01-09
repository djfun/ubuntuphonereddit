/*
 * Author: djfun <admin@djfun.de>
 * Date: 2013-01-09
 * Description: a simple Reddit search app
 *     as an example for writing apps for Ubuntu Phone
 *     with QML
 *     (here with inline javascript because of a bug with
 *     probably XMLHttpRequest)
*/

import QtQuick 2.0 
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem

Rectangle {
  id: root
  width: units.gu(60)
  height: units.gu(80)
  color: "white"

  Tabs {
    ItemStyle.class: "new-tabs"
    id: tabs
    anchors.fill: parent
    Tab {
      title: "Search"
      page: Rectangle {
        anchors.fill: parent
        id: search
        anchors.margins: units.gu(5)
        Column {
          spacing: units.gu(2)
          Row {
            spacing: units.gu(2)
            TextField {
              id: textFieldSearch
              placeholderText: "type your search text here"
              height: units.gu(4)
              width: units.gu(30)
            }
            Button {
              id: searchButton
              text: "Search"
              width: units.gu(12)
              onClicked: {
                indeterminateBar.visible = true
                //-------------------------------
                if (textFieldSearch.text != "") {
                  var req = new XMLHttpRequest();
                  req.onreadystatechange = function() {
                    if (req.readyState == XMLHttpRequest.DONE && req.status == 200) {
                      var responseJson = JSON.parse( req.responseText );
                      if (responseJson.kind == 'Listing') {
                        list1.model = responseJson.data.children;
                        tabs.selectedTabIndex = 1;
                      }
                      indeterminateBar.visible = false
                    }
                  }
                  req.open("GET", "http://www.reddit.com/search.json?q=" + encodeURIComponent(textFieldSearch.text));
                  req.send();
                }
                //-------------------------------
              }
            }
          }
          ProgressBar {
            id: indeterminateBar
            indeterminate: true
            width: units.gu(44)
            visible: false
          }
        }
      }
    }
    Tab {
      title: "Results"
      page: ListView {
        anchors.fill: parent
        id: list1

        property int selectedIndex: -1
        model: null
        delegate: ListItem.Empty {
          Row {
            spacing: units.gu(2)
            UbuntuShape {
              width: units.gu(6)
              height: units.gu(6)
              image: Image {
                function getImageUrl(thumbnail) {
                  if (thumbnail) {
                    if (thumbnail.substr(0, 4) == 'http') {
                      return Qt.resolvedUrl(thumbnail)
                    }
                  }
                  return Qt.resolvedUrl("empty.png")
                }
                source: getImageUrl(modelData.data.thumbnail)
              }
            }
            Label {
              text: modelData.data.title
            }
          }
          selected: index == list1.selectedIndex
          onClicked: {
            list1.selectedIndex = index
            onClicked: Qt.openUrlExternally(modelData.data.url)
          }
        }
      }
    }
  }
}