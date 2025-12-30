import QtQuick 2.0
import Sailfish.Silica 1.0

import dev.chrastecky 1.0

Page {
    id: page
    allowedOrientations: defaultAllowedOrientations

    Intl {
        id: intl
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: page.width
            spacing: Theme.paddingLarge

            PageHeader {
                //: Page title
                //% "Settings"
                title: qsTrId("page-settings")
            }

            ComboBox {
                property var itemData: [
                    //: As in automatic language selection
                    //% "Automatic"
                    {text: qsTrId("language-auto"), value: ""}
                ]

                id: langSelect
                width: parent.width - Theme.paddingLarge
                x: Theme.paddingLarge
                //% "Language"
                label: qsTrId("language-label")

                menu: ContextMenu {
                    Repeater {
                        model: langSelect.itemData
                        MenuItem {
                            property string value: modelData.value
                            text: modelData.text
                        }
                    }
                }

                onCurrentItemChanged: {
                    settings.rawLanguage = currentItem.value;
                }

                Component.onCompleted: {
                    const newData = itemData;
                    for (var index in appRoot.languages) {
                        if (!appRoot.languages.hasOwnProperty(index)) {
                            continue;
                        }
                        const language = appRoot.languages[index];
                        newData.push({text: intl.nativeLanguageName(language), value: language});
                    }

                    itemData = newData;

                    const index = itemData.map(function(item) {
                        return item.value;
                    }).indexOf(settings.rawLanguage);
                    currentIndex = index;
                }
            }
        }
    }
}
