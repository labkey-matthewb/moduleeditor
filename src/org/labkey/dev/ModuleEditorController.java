package org.labkey.dev;

import org.labkey.api.action.SimpleViewAction;
import org.labkey.api.action.SpringActionController;
import org.labkey.api.security.RequiresPermission;
import org.labkey.api.security.permissions.ReadPermission;
import org.labkey.api.view.JspView;
import org.labkey.api.view.NavTree;
import org.springframework.validation.BindException;
import org.springframework.web.servlet.ModelAndView;

/**
 * Created by matthew on 6/4/15.
 */
public class ModuleEditorController extends SpringActionController
{
    private static ActionResolver _actionResolver = new DefaultActionResolver(ModuleEditorController.class);

    public ModuleEditorController()
    {
        setActionResolver(_actionResolver);
    }

    public static class PathForm
    {
        String path;

        public String getPath()
        {
            return path;
        }

        @SuppressWarnings("unused")
        public void setPath(String path)
        {
            this.path = path;
        }
    }

    @RequiresPermission(ReadPermission.class)
    @SuppressWarnings("unused")
    public static class EditAction extends SimpleViewAction<PathForm>
    {
        @Override
        public ModelAndView getView(PathForm form, BindException errors)
        {
            return new JspView<>("/org/labkey/dev/edit.jsp",form);
        }

        @Override
        public NavTree appendNavTrail(NavTree root)
        {
            return root;
        }
    }
}
