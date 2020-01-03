package org.labkey.dev;

import org.labkey.api.action.SimpleViewAction;
import org.labkey.api.action.SpringActionController;
import org.labkey.api.module.Module;
import org.labkey.api.module.ModuleLoader;
import org.labkey.api.security.RequiresPermission;
import org.labkey.api.security.permissions.ReadPermission;
import org.labkey.api.view.JspView;
import org.labkey.api.view.NavTree;
import org.labkey.api.view.NotFoundException;
import org.labkey.api.view.template.PageConfig;
import org.springframework.validation.BindException;
import org.springframework.web.servlet.ModelAndView;

import static org.apache.commons.lang3.StringUtils.isBlank;

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
        String module;
        String path;

        public String getModule()
        {
            return module;
        }

        public void setModule(String module)
        {
            this.module = module;
        }

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
        Module module;

        @Override
        public ModelAndView getView(PathForm form, BindException errors)
        {
            if (!getContainer().isRoot())
                throw new NotFoundException();

            if (isBlank(form.getModule()))
            {
                getPageConfig().setTemplate(PageConfig.Template.Dialog);
                return new JspView<>("/org/labkey/dev/choosemodule.jsp", form);
            }

            module = ModuleLoader.getInstance().getModule(form.getModule());
            if (null == module)
                throw new NotFoundException();

            return new JspView<>("/org/labkey/dev/edit.jsp",form);
        }

        @Override
        public NavTree appendNavTrail(NavTree root)
        {
            if (null != module)
                root.addChild(module.getName() + " - Module Editor");
            return root;
        }
    }
}
