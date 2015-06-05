package org.labkey.dev;

import org.labkey.api.action.SpringActionController;

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
}
