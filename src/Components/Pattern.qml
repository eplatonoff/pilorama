import QtQuick 2.0


import "Pattern"

Item {
   id: pattern

   PatternModel {
       id: patternModel
   }

   Rectangle {

       color: colors.get()
       anchors.top: patternHeader.bottom
       anchors.right: parent.right
       anchors.bottom: parent.bottom
       anchors.left: parent.left
       anchors.topMargin: 0
//        Behavior on color { ColorAnimation { duration: 100 } }

       ListView {
           id: patternSet
           anchors.fill: parent
           spacing: 0
           cacheBuffer: 40
           orientation: ListView.Vertical
           model: patternModel
           delegate: PatternItem {
           }
       }


   }

   Header {
       id: patternHeader
       anchors.top: parent.top
       anchors.topMargin: 0
       anchors.left: parent.left
       anchors.leftMargin: 0
       anchors.right: parent.right
       anchors.rightMargin: 0
   }

}
