// vim:set fdm=marker et sw=4 ts=4:
// INFO {{{
let INFO = xml`
<plugin name="treeStyleTab" version="0.0.3"
        href="http://github.com/caisui/vimperator/blob/master/plugin/treeStyleTab.js"
        summary="Tree Stye Tab"
        xmlns="http://vimperator.org/namespaces/liberator">
    <author href="http://d.hatena.ne.jp/caisui">caisui</author>
    <license href="http://www.opensource.org/licenses/bsd-license.php">New BSD License</license>
    <project name="Vimperator" minVersion="2.0"/>
    <item>
        <description>
            Tree Style Tab を 操作 するためのpluginです<br/>

            <li>2011.03.10 Firefox 4.0b13pre で 動作確認</li>
        </description>
    </item>
    <item>
        <tags> g:disabled_tree_style_tab_default_map </tags>
        <spec> let g:disabled_tree_style_tab_default_map </spec>
        <type>boolean</type>
        <default>false</default>
        <description>
            plugin 標準 map の 定義 を しない
        </description>
    </item>
    <item>
        <tags> g:disabled_tree_style_tab_reload_action </tags>
        <spec> let g:disabled_tree_style_tab_reload_action </spec>
        <type>boolean</type>
        <default>false</default>
        <description>
            about:blank に対して <k name="r"/> で about:treestyletab-group に 置換する機能を利用しない
        </description>
    </item>
    <item>
        <tags> plugins.treeStyleTab.control.scrollIntoView </tags>
        <spec> plugins.treeStyleTab.control.scrollIntoView </spec>
        <description>
            mapping sample
            <code><![CDATA[
                mappings.addUserMap([modes.NORMAL], ["gzz"], "selected tab scroll to center", function (count) {
                    plugins.treeStyleTab.control.scrollIntoView(gBrowser.selectedTab, -1, count || 50);
                }, { count: true});
            ]]></code>
        </description>
    </item>
</plugin>`;
// }}}

(function () {
    if(!("TreeStyleTabService" in window)) return;
    const self = this;

    var extra = {count: true};

    var setup = function (key, desc, f) {
        mappings.remove([modes.NORMAL], key);
        mappings.addUserMap([modes.NORMAL], [key], desc, function () self.control[f].apply(self.control, arguments), extra);
    };

    if (!liberator.globalVariables.disabled_tree_style_tab_default_map) //set mapping{{{
    {
        setup("zn"   , "tree style tab next parent tab" , "nextParentTab");
        setup("zN"   , "tree style tab next root tab"   , "nextRootTab");
        setup("zj"   , "tree style tab next tab"        , "nextTab");
        setup("zp"   , "tree style tab prev parent tab" , "prevParentTab");
        setup("zP"   , "tree style tab prev root tab"   , "prevRootTab");
        setup("zk"   , "tree style tab prev tab"        , "prevTab");
        setup("zd"   , "remove tree tab"                , "removeTabSubTree");
        setup("zD"   , "remove tree tab from top tree"  , "removeTabTreeAll");
        setup("zh"   , "tree style tab parent tab"      , "parentTab");
        setup("zH"   , "tree style tab root tab"        , "rootTab");
        setup("zl"   , "tree style tab first child tab" , "firstChildTab");
        setup("zL"   , "tree style tab first child tab" , "lastChildTab");
        setup("zu"   , "move up"                        , "moveUp");
        setup("zU"   , "move root"                      , "moveRoot");
        setup("d"    , "override remove tab"            , "removeTab");
        setup("zc"   , "collapse subtree"               , "collapseSubtree");
        setup("zC"   , "collapse subtree from root tab" , "collapseSubtreeFromRoot");
        setup("zm"   , "collapse all subtree"           , "collapseAllSubtree");
        setup("zo"   , "expand subtree"                 , "expandSubtree");
        setup("z^"   , "goto first tab"                 , "firstTab");
        setup("z$"   , "goto last tab"                  , "lastTab");
        setup("z@"   , "ready to open child tab once"   , "readyToOpenChildTabOnce");
        setup("z'"   , "ready to open child tab once"   , "readyToOpenTabOnce");
        setup("z["   , "ready to open child tab"        , "readyToOpenChildTab");
        setup("z]"   , "stop to open child tab"         , "stopToOpenChildTab");
        setup("zg"   , "show tabbar"                    , "showTabbar");
        setup("zx"   , "mark tab"                       , "setMarkTab");
        setup("zv"   , "move child tab"                 , "moveChildTab");
        setup("zV"   , "show next tab"                  , "moveNextTab");
        setup("zt"   , "open new tab child tab"         , "tabOpenChild");
        setup("zJ"   , "move tab(direction:next)"       , "moveTabToNext");
        setup("zK"   , "move tab(direction:previous)"   , "moveTabToPrebious");
        setup("<<"   , "move tab to parent"             , "moveTabToParent");
        setup(">>"   , "move tab to child"              , "moveTabToChild");
    }
    //}}}

    const g = gBrowser;
    XPCOMUtils.defineLazyGetter(self, "T", function () { return gBrowser.treeStyleTab; });

    function repeat(aCount, func) {
        for (let i = 0; i < aCount; ++i) {
            if (func(i) === false) break;
        }
    }

    let U1 = this.helper = //{{{
    {
        getLastRootTab: function () T.getRootTab(T.getLastTab(g)),
        gene_iterator: function (funcName, aTab, aLoop) {
            var action = T[funcName];
            while (1)  {
                aTab = action.call(T, aTab) || aLoop;
                if (!aTab) break;
                if (!aTab.hidden)
                    yield aTab;
            }
        },
        getNextTab: function (aTab, aCount) {
            var p = T.getParentTab(aTab);
            var it = U1.gene_iterator("getNextSiblingTab", aTab, p ? T.getFirstChildTab(p) : T.getFirstTab(g));
            while (aCount-->1) it.next();
            return it.next();
        },
        getPrevTab: function (aTab, aCount) {
            var p = T.getParentTab(aTab);
            var it = U1.gene_iterator("getPreviousSiblingTab", aTab, p ? T.getLastChildTab(p) : U1.getLastRootTab());
            while(aCount-->1) it.next();
            return it.next();
        },
        getNextSiblingVisibleTab: function (aTab) {
            while ((aTab = T.getNextSiblingTab(aTab)) && aTab.hidden);
            return aTab;
        },
        getPreviousSiblingVisibleTab: function (aTab) {
            while ((aTab = T.getPreviousSiblingTab(aTab)) && aTab.hidden);
            return aTab;
        },
        getParentTab: function (aTab, aCount) {
            let tab;
            for(let i = 0; i < aCount; ++i) {
                tab = T.getParentTab(aTab);
                if(tab) aTab = tab;
                else break;
            }return aTab;
        },
        performDrop: function (aTab, pTab, iTab) {
            if(!aTab) return;
            else if(pTab && T.getDescendantTabs(aTab).indexOf(pTab)>= 0) {
                liberator.echoerr("error:loop");
                return;
            }
            T.performDrop({
                action: (pTab ? T.kACTION_ATTACH : T.kACTION_PART) | T.kACTION_MOVE,
                parent: pTab,
                source: aTab,
                insertBefore: iTab,
                canDrop: true,
                //position: 0, //?
                //target: null,//?
            }, aTab);
        },
        readyToOpenChildTabCore: function (aTab, aFlag) {
            T.readyToOpenChildTab(aTab, aFlag);
            var e = document.getElementById("liberator-statusline");
            e.setAttribute("style", "color:red;");
        },
        moveTabSubTreeToEx: function (aTab, aCount, reverse) {
            aCount = aCount || 1;
            if (aCount == -1) aCount = 1;

            var it = U1.gene_iterator(reverse ? "getPreviousSiblingTab" : "getNextSiblingTab", aTab, null);
            try {
                var prevTab;
                while (aCount-- > 0)
                    prevTab = it.next();
            } catch (ex) { }

            if (!prevTab || aTab === prevTab) return;

            if (!reverse) {
                let lastTab = T.getLastDescendantTab(prevTab);
                if (lastTab)
                    prevTab = lastTab;
            }

            if (aTab !== prevTab)
                T.moveTabSubTreeTo(aTab, prevTab._tPos);
        }
    };//}}}

    let U2 = this.control = //{{{
    {
        nextTab: function (aCount) {
            g.selectedTab = U1.getNextTab(g.selectedTab, aCount);
        },
        nextParentTab: function (aCount) {
            var t = gBrowser.selectedTab;
            g.selectedTab = U1.getNextTab(T.getParentTab(t) || T.getRootTab(t), aCount);
        },
        nextRootTab: function (aCount) {
            g.selectedTab = U1.getNextTab(T.getRootTab(g.selectedTab), aCount);
        },
        prevTab: function (aCount) {
            g.selectedTab = U1.getPrevTab(g.selectedTab, aCount);
        },
        prevParentTab: function (aCount) {
            var t = g.selectedTab;
            g.selectedTab = U1.getPrevTab(T.getParentTab(t) || t, aCount);
        },
        prevRootTab: function (aCount) {
            g.selectedTab = U1.getPrevTab(T.getRootTab(g.selectedTab, aCount), aCount);
        },
        removeTab: function () {
            let t = g.selectedTab;
            if (!T.hasChildTabs(t)) {
                let newTab = U1.getNextSiblingVisibleTab(t);
                if (!newTab)
                    newTab = U1.getPreviousSiblingVisibleTab(t) || T.getParentTab(t);
                g.selectedTab = newTab;
            }
            g.removeTab(t);
        },
        parentTab: function (aCount) {
            g.selectedTab = U1.getParentTab(g.selectedTab, Math.max(aCount, 1));
        },
        rootTab: function () {
            g.selectedTab = T.getRootTab(g.selectedTab);
        },
        firstChildTab: function () {
            var t = T.getFirstChildTab(g.selectedTab);
            if(t) g.selectedTab = t;
        },
        lastChildTab: function () {
            var t = T.getLastChildTab(g.selectedTab);
            if(t) g.selectedTab = t;
        },
        removeTabSubTree: function (aCount) {
            if(aCount > 0) U2.parentTab(aCount);
            U2.collapseSubtree(0);
            let t = g.selectedTab;
            g.selectedTab = U1.getNextSiblingVisibleTab(t) || U1.getPreviousSiblingVisibleTab(t) || T.getParentTab(t) || t;
            g.removeTab(t);
        },
        removeTabTreeAll: function () {
            g.selectedTab = T.getRootTab(g.selectedTab);
            U2.removeTabSubTree(0);
        },
        collapseSubtree: function (aCount) {
            if(aCount > 0) U2.parentTab(aCount);
            T.collapseExpandSubtree(g.selectedTab, true);
        },
        collapseSubtreeFromRoot: function () {
            T.collapseExpandSubtree(T.getRootTab(g.selectedTab), true);
        },
        expandSubtree: function () {
            T.collapseExpandSubtree(g.selectedTab, false);
        },
        collapseAllSubtree: function () {
            T.collapseExpandAllSubtree(true);
        },
        firstTab: function () {
            var t = g.selectedTab;
            var p = T.getParentTab(t);
            g.selectedTab = p ? T.getFirstChildTab(p) : T.getFirstTab(g);
        },
        lastTab: function () {
            var t = g.selectedTab;
            var p = T.getParentTab(t);
            g.selectedTab = p ? T.getLastChildTab(p) : U1.getLastRootTab();
        },
        readyToOpenChildTabOnce: function () {
            U1.readyToOpenChildTabCore(g.selectedTab);
        },
        readyToOpenTabOnce: function () {
            var t = g.selectedTab;
            U1.readyToOpenChildTabCore(T.getParentTab(t) || t);
        },
        readyToOpenTabPaste: function () {
            try{
            U1.readyToOpenChildTabCore(g.selectedTab, true);
            mappings.get(modes.NORMAL, "P").action();
            U2.stopToOpenChildTab();
            }catch(ex){liberator.echoerr(ex);}
        },
        readyToOpenChildTab: function () {
            U1.readyToOpenChildTabCore(g.selectedTab, true);
        },
        stopToOpenChildTab: function () {
            T.stopToOpenChildTab(g.selectedTab);
            var e = document.getElementById("liberator-statusline");
            e.removeAttribute("style");
        },
        showTabbar: function () {
            T.showTabbar();
        },
        setMarkTab: function () {
            this.markTab = g.selectedTab;
        },
        assertHiddenPinned: function (aTab) {
            liberator.assert(!this.markTab.hidden, "not supported: another group move");

            liberator.assert(!this.markTab.pinned, "not supported: pinned tab move");
            liberator.assert(!aTab.pinned, "not supported: pinned tab move");
        },
        moveChildTab: function () {
            this.assertHiddenPinned(gBrowser.selectedTab);

            var t = g.selectedTab;
            if(this.markTab && T.getDescendantTabs(this.markTab).indexOf(t)>= 0) {
                liberator.echoerr("error:loop");
                return;
            }
            T.partTab(this.markTab);
            T.attachTabTo(this.markTab, t);
        },
        moveNextTab: function () {
            this.assertHiddenPinned(gBrowser.selectedTab);

            var aTab = gBrowser.selectedTab;
            var aParent = T.getParentTab(aTab);
            var aNext = T.getNextSiblingTab(aTab);

            if (aTab === this.markTab || aNext === this.markTab) return;
            else {
                T.partTab(this.markTab);
                T.attachTabTo(this.markTab, aTab);
                T.promoteTab(this.markTab);
            }
        },
        moveUp: function (aCount) {
            repeat(Math.max(aCount, 1), function () T.promoteCurrentTab());
        },
        moveRoot: function () {
            let aTab = g.selectedTab;
            let aRoot = T.getRootTab(aTab);
            let aNext = T.getNextSiblingTab(aRoot);
            if (aNext)
                g.moveTabTo(aTab, aNext._tPos -1);
            else
                g.moveTabToEnd();
            T.partTab(aTab);
        },
        moveDown: function (aCount) {
            let tab1 = gBrowser.selectedTab;
            if (T.getParentTab(tab1)) {
                repeat(Math.max(aCount, 1), function () T.demoteCurrentTab());
            } else {
                let tab2 = U1.getPreviousSiblingVisibleTab(tab1);
                if (!tab2) return;
                T.partTab(tab1);
                T.attachTabTo(tab1, tab2);
                if (aCount > 1) this.moveDown(aCount - 1);
            }
        },
        tabOpenChild: function (aCount) {
            T.readyToOpenChildTab(U1.getParentTab(g.selectedTab, aCount), false);
            commandline.open(":", "tabopen ", liberator.modules.modes.EX);
        },
        moveTabToNext: function (aCount) {
            U1.moveTabSubTreeToEx(g.selectedTab, aCount);
        },
        moveTabToPrebious: function (aCount) {
            U1.moveTabSubTreeToEx(g.selectedTab, aCount, true);
        },
        moveTabToParent: function (aCount) {
          let grandParent = TreeStyleTabService.getParentTab(
              TreeStyleTabService.getParentTab(g.selectedTab));

          if (grandParent) {
            T.attachTabTo(g.selectedTab, grandParent);
          } else {
            T.partTab(g.selectedTab);
          }
        },
        moveTabToChild: function (aCount) {
          T.attachTabTo(g.selectedTab,
              TreeStyleTabService.getPreviousSiblingTab(g.selectedTab));
        },
        scrollIntoView: function scrollIntoView(aTab, aVPercent, aHPercent) {
            if (!aTab) aTab = gBrowser.selectedTab;
            var tst = gBrowser.treeStyleTab;
            var box1 = tst.scrollBoxObject;
            var box2 = gBrowser.selectedTab.boxObject;
            var x = {};
            var y = {};
            box1.getPosition(x, y);

            if (aVPercent >= 0)
                x = (box2.y - box2.y) - (box1.width - box2.width) * aVPercent / 100;
            else
                x = x.value;

            if (aHPercent >= 0)
                var y = (box2.y - box1.y) - (box1.height - box2.height) * aHPercent / 100;
            else
                y = y.value;

            tst.scrollTo(x, y);
        },
    };//}}}

    //override reload map about:blank & treestyletab-group{{{
    if (!liberator.globalVariables.disabled_tree_style_tab_reload_action) {
        let map = mappings.get(modes.NORMAL, "r");
        const aURI = "about:treestyletab-group";
        mappings.addUserMap([modes.NORMAL], ["r"], map.description + " (treeStyleTab.js mode)", function () {
            let uri = content.document.location.href;
            if (uri === "about:blank")
                commandline.open(":", xml`open {aURI}?`.toString(), modes.EX);
            else if (uri.substr(0, aURI.length) === aURI)
                commandline.open("", "open " + util.losslessDecodeURI(uri), modes.EX);
            else
                tabs.reload(config.browser.mCurrentTab, false);
        });
    }//}}}
}).call(this);

