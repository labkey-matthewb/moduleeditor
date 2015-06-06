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
        resources.add(ClientDependency.fromPath("codemirror"));
        return resources;
    }
%>
<%
    ModuleEditorController.PathForm form = (ModuleEditorController.PathForm)HttpView.currentModel();
    String path = form.getPath();
%>
<%=button("Save")%>
<p></p>
<div id="path"></div>
<p></p>
<textarea id="moduleEditor" style="height:600px; width:800px;">
</textarea>
<script>
LABKEY.Utils.onReady(function ()
{
    var path = <%=q(path)%>;
    if (!path && window.location.hash)
        path = window.location.hash.substring(1);
    if (!Ext4.String.startsWith(path,"/"))
        path = "/" + path;
    path = <%=q(getContextPath())%> + "/_webdav/@modules" + path;
    Ext4.get("path").update(Ext4.htmlEncode(path));
    // Create json editor
    var editor = CodeMirror.fromTextArea(document.getElementById("moduleEditor"),
    {
        mode: {name: 'javascript', json: true},
        lineNumbers: true,
        lineWrapping: false
    });

    editor.setSize(800, 300);
    LABKEY.codemirror.RegisterEditorInstance('moduleEditor', editor);
});
</script>