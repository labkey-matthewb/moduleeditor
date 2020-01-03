<%
    /*
     * Copyright (c) 2015 LabKey Corporation
     *
     * Licensed under the Apache License, Version 2.0 (the "License");
     * you may not use this file except in compliance with the License.
     * You may obtain a copy of the License at
     *
     *     http://www.apache.org/licenses/LICENSE-2.0
     *
     * Unless required by applicable law or agreed to in writing, software
     * distributed under the License is distributed on an "AS IS" BASIS,
     * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
     * See the License for the specific language governing permissions and
     * limitations under the License.
     */
%>
<%@ page import="org.labkey.api.view.HttpView" %>
<%@ page import="org.labkey.api.view.template.ClientDependency" %>
<%@ page import="org.labkey.dev.ModuleEditorController" %>
<%@ page import="org.labkey.api.view.template.ClientDependencies" %>
<%@ page import="org.labkey.api.module.ModuleLoader" %>
<%@ page import="org.labkey.api.module.Module" %>
<%@ page import="org.labkey.api.view.NotFoundException" %>
<%@ page extends="org.labkey.api.jsp.JspBase" %>
<%@ taglib prefix="labkey" uri="http://www.labkey.org/taglib" %>
<%!
    public void addClientDependencies(ClientDependencies dependencies)
    {
        dependencies.add(ClientDependency.fromPath("Ext4"));
        dependencies.add(ClientDependency.fromPath("File"));
        dependencies.add(ClientDependency.fromPath("codemirror"));
    }
%>
<%
    ModuleEditorController.PathForm form = (ModuleEditorController.PathForm)HttpView.currentModel();
    Module module = ModuleLoader.getInstance().getModule(form.getModule());
    if (null == module)
        throw new NotFoundException();
%>
<%--<table>
<tr>
<td>
    <div id="filepicker" style="height:600px; width:300px;"></div>
</td>
<td>
    <div id="path" style="margin:5pt; padding:3pt; border:solid gray 1px;">&nbsp;</div>
    <div id="sourcePath" style="margin:5pt; padding:3pt; border:solid gray 1px;">&nbsp;</div>
    <textarea id="moduleEditor" style="height:600px; width:800px;"></textarea>
    <%=button("Save").id("save").build()%>
</td>
</tr></table>
--%>
<div id="moduleEditorApp"></div>

<script type="text/javascript">
// model with sourcePath added
Ext4.define('File.data.webdav.XMLResponse.EDITOR',
{
    extend: 'File.data.webdav.XMLResponse',
    constructor: function ()
    {
        this.fields.add({name: 'sourcePath', mapping: 'propstat/prop/custom/sourcePath'});
        this.callParent(arguments);
    }
});

(function(moduleName, targetDiv)
{
    var editor;
    var fileSystem;
    var btnSave;
    var currentOpenRecord = null;
    var beep = new Audio("data:audio/wav;base64,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qJrx4KOQjahZxWbcZgztj2c49nKmkId44S71j0c8eV9yDK6uPRzx5X18eDvjvQ6yKo9ZSS6l//8elePK/Lf//IInrOF/FvDoADYAGBMGb7FtErm5MXMlmPAJQVgWta7Zx2go+8xJ0UiCb8LHHdftWyLJE0QIAIsI+UbXu67dZMjmgDGCGl1H+vpF4NSDckSIkk7Vd+sxEhBQMRU8j/12UIRhzSaUdQ+rQU5kGeFxm+hb1oh6pWWmv3uvmReDl0UnvtapVaIzo1jZbf/pD6ElLqSX+rUmOQNpJFa/r+sa4e/pBlAABoAAAAA3CUgShLdGIxsY7AUABPRrgCABdDuQ5GC7DqPQCgbbJUAoRSUj+NIEig0YfyWUho1VBBBA//uQZB4ABZx5zfMakeAAAAmwAAAAF5F3P0w9GtAAACfAAAAAwLhMDmAYWMgVEG1U0FIGCBgXBXAtfMH10000EEEEEECUBYln03TTTdNBDZopopYvrTTdNa325mImNg3TTPV9q3pmY0xoO6bv3r00y+IDGid/9aaaZTGMuj9mpu9Mpio1dXrr5HERTZSmqU36A3CumzN/9Robv/Xx4v9ijkSRSNLQhAWumap82WRSBUqXStV/YcS+XVLnSS+WLDroqArFkMEsAS+eWmrUzrO0oEmE40RlMZ5+ODIkAyKAGUwZ3mVKmcamcJnMW26MRPgUw6j+LkhyHGVGYjSUUKNpuJUQoOIAyDvEyG8S5yfK6dhZc0Tx1KI/gviKL6qvvFs1+bWtaz58uUNnryq6kt5RzOCkPWlVqVX2a/EEBUdU1KrXLf40GoiiFXK///qpoiDXrOgqDR38JB0bw7SoL+ZB9o1RCkQjQ2CBYZKd/+VJxZRRZlqSkKiws0WFxUyCwsKiMy7hUVFhIaCrNQsKkTIsLivwKKigsj8XYlwt/WKi2N4d//uQRCSAAjURNIHpMZBGYiaQPSYyAAABLAAAAAAAACWAAAAApUF/Mg+0aohSIRobBAsMlO//Kk4soosy1JSFRYWaLC4qZBYWFRGZdwqKiwkNBVmoWFSJkWFxX4FFRQWR+LsS4W/rFRb/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////VEFHAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAU291bmRib3kuZGUAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMjAwNGh0dHA6Ly93d3cuc291bmRib3kuZGUAAAAAAAAAACU=");

    LABKEY.Utils.onReady(Editor_onPageReady);

    function Editor_onPageReady()
    {
        // Ext4.get("save").on("click",Save_onClick);

        // FILE TREE
        fileSystem = Ext4.create('File.system.Webdav',
                {
                    containerPath: "/",
                    rootPath: LABKEY.contextPath + "/_webdav/@modules/" + moduleName,
                    rootName: moduleName
                });
        var proxy = Ext4.apply(fileSystem.getProxyCfg('xml'),
                {
                    requestFiles: true,
                    extraPropNames: ['custom']
                });
        var storeConfig =
        {
            model: 'File.data.webdav.XMLResponse.EDITOR',
            proxy: proxy,
            root: {
                text: fileSystem.rootName,
                name: fileSystem.rootName,
                id: fileSystem.getBaseURL(),
                uri: fileSystem.getAbsoluteURL(),
                expanded: true,
                icon: LABKEY.contextPath + '/_images/labkey.png'
            }
        };
        var fileTreeConfig =
        {
            xtype: 'treepanel',
            itemId: 'lk-resource-tree',
            id: 'lk-resource-tree',
            store: Ext4.create('Ext.data.TreeStore', storeConfig),
            header: false,
            rootVisible: true,
            autoScroll: true,
            containerScroll: true,
            collapsible: false,
            collapsed: false,
            cmargins: '0 0 0 0',
            border: true,
            stateful: false,
            pathSeparator: ';',
            listeners: {
                select: FileTree_onSelect
            }
        };
        // filetree = Ext4.create('Ext.tree.Panel', config);
        // filetree.on({select: FileTree_onSelect});
        // filetree.render('filepicker);

        var sourceEditorConfig =
        {
            itemId : "lk-source-editor",
            id : "lk-source-editor",
            xtype : 'container',
            html: "<textarea id=\"moduleEditor\" style=\"height:100%; width:100%;\"></textarea>\n"
        };

        var application = Ext4.create('Ext.form.Panel',
        {
            renderTo: targetDiv,
            layout: 'border',

            // allow this component to resize the height to fit the browser window
            autoResize: {
                skipHeight: false
            },

            width: '100%',

            items:
            [
                // HELP I can't get toolbars to works
                {items:[(btnSave = Ext4.create('Ext.button.Button', {id: 'lk-save-btn', text:'Save', disabled:true}))], region:"north", flex: 0, height:30},
                Ext4.apply(fileTreeConfig,{region:"west", split: true, flex: 1, minWidth: 200}),
                Ext4.apply(sourceEditorConfig, {region : "center", flex: 5, minWidth: 400})
            ],

            listeners: {
                render: function()
                {
                    var el = Ext4.get("moduleEditor");
                    editor = CodeMirror.fromTextArea(el.dom,
                            {
                                mode: {name: 'javascript', json: true},
                                lineNumbers: true,
                                lineWrapping: false
                            });
                    LABKEY.codemirror.RegisterEditorInstance('moduleEditor', editor);
                    editor.setOption("readOnly", true);

                    // Ext4.get('lk-save-btn').on('click',function() {alert("on click before");});
                    Ext4.get('lk-save-btn').on('click',Save_onClick);
                    // Ext4.get('lk-save-btn').on('click',function() {alert("on click after");});
                }
            }
        });
    }


    function FileTree_onSelect(tree, record, index, eOpts)
    {
        if (!record.get("file"))
            return;
        var contentType = (record.get("contentType") || record.get("contenttype") || "").toLowerCase();
        var isText = Ext4.String.startsWith(contentType, "text/") || contentType === "application/x-javascript" || contentType === "application/x-typescript";
        if (!isText)
        {
            beep.play();
            return;
        }
        var isCode = contentType === "text/x-java-source";
        var isReadOnly = !record.get("options")["PUT"] || isCode;
        openFile(record, isReadOnly);
    }

    function openFile(record, isReadOnly)
    {
        var moduleName = "";
        var displayPath = record.get("path");

        //TODO it seems like a bug to me that record.get("path") does not return a path relative to the filesystem root
        if (Ext4.String.startsWith(displayPath, "/_webdav/@modules/"))
        {
            displayPath = displayPath.substring("/_webdav/@modules/".length);
            var s = displayPath.indexOf('/');
            if (s !== -1)
            {
                moduleName = displayPath.substring(0, s);
                displayPath = displayPath.substring(s);
            }
        }

        Ext4.Ajax.request(
        {
            url: record.get("uri"),
            success: function (response)
            {
                editor.setOption("readOnly", isReadOnly);
                btnSave.setDisabled(isReadOnly);
                editor.setValue(response.responseText);
                currentOpenRecord = record;
                // Ext4.get('moduleName').update(moduleName ? Ext4.htmlEncode(moduleName) : "&nbsp;");
                // Ext4.get('path').update(displayPath ? Ext4.htmlEncode(displayPath) : "&nbsp;");
                // Ext4.get('sourcePath').update(sourcePath ? Ext4.htmlEncode(record.get("sourcePath")) : "&nbsp;");
            }
        });
    }

    function Save_onClick()
    {
        if (!currentOpenRecord)
        {
            beep.play();
            return;
        }
        var record = currentOpenRecord;
        var uri = record.get("uri");
        var i = uri.lastIndexOf("/");
        var parent = uri.substring(0, i);
        var filename = uri.substring(i + 1);

        Ext4.Ajax.request(
        {
            url: parent,
            method: 'POST',
            params: {filename: filename, content: editor.getValue()},
            success: function (response)
            {
                alert(filename + ' saved');
            }
        });
    }
})(<%=q(module.getName())%>, "moduleEditorApp");
</script>
