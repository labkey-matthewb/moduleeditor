<%
    /*
     * Copyright (c) 2020 LabKey Corporation
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
<%@ page import="org.labkey.api.module.ModuleLoader" %>
<%@ page import="static org.labkey.api.util.DOM.DIV" %>
<%@ page import="static org.labkey.api.util.DOM.A" %>
<%@ page import="static org.labkey.api.util.DOM.at" %>
<%@ page import="static org.labkey.api.util.DOM.Attribute.*" %>
<%@ page import="org.labkey.api.util.Link" %>
<%@ page import="org.labkey.api.view.ActionURL" %>
<%@ page import="org.labkey.dev.ModuleEditorController" %>
<%@ page import="static org.labkey.api.util.DOM.NOAT" %>
<%@ page extends="org.labkey.api.jsp.JspBase" %>
<%@ taglib prefix="labkey" uri="http://www.labkey.org/taglib" %>

<%
    DIV(NOAT, ModuleLoader.getInstance().getModules().stream().map( module ->
        {
            ActionURL edit = new ActionURL(ModuleEditorController.EditAction.class,getContainer()).addParameter("module",module.getName());
            return DIV(NOAT,new Link.LinkBuilder(module.getName()).href(edit));
        }
    )).appendTo(out);
%>