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
<%@ page import="java.util.LinkedHashSet" %>
<%@ page import="org.labkey.dev.ModuleEditorController" %>
<%@ page extends="org.labkey.api.jsp.JspBase" %>
<%@ taglib prefix="labkey" uri="http://www.labkey.org/taglib" %>
<%!
    public LinkedHashSet<ClientDependency> getClientDependencies()
    {
        LinkedHashSet<ClientDependency> resources = new LinkedHashSet<>();
        resources.add(ClientDependency.fromPath("Ext4"));
        resources.add(ClientDependency.fromPath("File"));
        resources.add(ClientDependency.fromPath("codemirror"));
        return resources;
    }
%>
<%
    ModuleEditorController.PathForm form = (ModuleEditorController.PathForm)HttpView.currentModel();
    String path = form.getPath();
%>
<p></p>
<table><tr>
<td>
    <div id="filepicker" style="height:600px; width:200px;"></div>
</td>
<td>
    <div id="path" style="height:14pt; border:solid gray 1px;"></div>
    <textarea id="moduleEditor" style="height:600px; width:800px;"></textarea>
    <%=button("Save").onClick("Save_onClick()").build()%>
</td>
</tr></table>
<script>
var editor;
var filetree;
var fileSystem;
var path;
var uri;
LABKEY.Utils.onReady(Editor_onPageReady);

function Editor_onPageReady()
{
    fileSystem = Ext4.create('File.system.Webdav',
        {
            rootPath: LABKEY.contextPath + "/_webdav/@modules/",
            rootName: 'Modules'
        });

    // EDITOR
    editor = CodeMirror.fromTextArea(document.getElementById("moduleEditor"),
    {
        mode: {name: 'javascript', json: true},
        lineNumbers: true,
        lineWrapping: false
    });
    editor.setSize(800, 600);
    LABKEY.codemirror.RegisterEditorInstance('moduleEditor', editor);


    // FILE TREE
    var storeConfig =
    {
        model : fileSystem.getModel('xml'),
        proxy : Ext4.apply({requestFiles:true}, fileSystem.getProxyCfg('xml')),
        root :
        {
            text : fileSystem.rootName,
            name : fileSystem.rootName,
            id : fileSystem.getBaseURL(),
            uri : fileSystem.getAbsoluteURL(),
            expanded : true,
            icon : LABKEY.contextPath + '/_images/labkey.png'
        }
    };
    var config =
    {
        itemId: Ext4.id(),
        id: Ext4.id(),
        store: Ext4.create('Ext.data.TreeStore', storeConfig),
        height: 600,
        width: 300,
        header: false,
        listeners : {},
        rootVisible     : true,
        autoScroll      : true,
        containerScroll : true,
        collapsible     : false,
        collapsed       : false,
        cmargins        : '0 0 0 0',
        border          : true,
        stateful        : false,
        pathSeparator   : ';',
        renderTo : 'filepicker'
    };
    filetree = Ext4.create('Ext.tree.Panel', config);
    filetree.on({select:FileTree_onSelect});
    filetree.render();
}


function FileTree_onSelect( tree, record, index, eOpts )
{
    if (!record.get("file"))
        return;
    var contentType = record.get("contentType") || record.get("contenttype");
    if (!Ext4.String.startsWith(contentType,"text/"))
        return;
    openFile(record);
}

function openFile(record)
{
    uri = null;
    path = null;

    var openuri = record.get("uri");
    var openpath = record.get("path");
    Ext4.Ajax.request(
    {
        url: openuri,
        success: function(response)
        {
            editor.setValue(response.responseText);
            uri = openuri;
            path = openpath;
            Ext4.get('path').update(Ext4.htmlEncode(path));
        }
    });
}

function Save_onClick()
{
    var i = uri.lastIndexOf("/");
    var parent = uri.substring(0,i);
    var filename = uri.substring(i+1);

    Ext4.Ajax.request(
    {
        url: parent,
        method:'POST',
        params:{filename:filename, content:editor.getValue()},
        success: function(response)
        {
            alert(path + ' saved');
        }
    });
}


</script>