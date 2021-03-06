package org.labkey.dev;

import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;
import org.labkey.api.exp.api.ExpData;
import org.labkey.api.module.DefaultModule;
import org.labkey.api.module.Module;
import org.labkey.api.module.ModuleLoader;
import org.labkey.api.security.SecurityPolicy;
import org.labkey.api.security.User;
import org.labkey.api.settings.AppProps;
import org.labkey.api.util.FileStream;
import org.labkey.api.util.FileUtil;
import org.labkey.api.util.Path;
import org.labkey.api.view.NavTree;
import org.labkey.api.webdav.AbstractWebdavResourceCollection;
import org.labkey.api.webdav.DavException;
import org.labkey.api.webdav.FileSystemResource;
import org.labkey.api.webdav.WebdavResolver;
import org.labkey.api.webdav.WebdavResource;
import org.labkey.api.webdav.WebdavService;
import org.labkey.api.writer.ContainerUser;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;

/**
 * Created by matthew on 6/4/15.
 */
public class ModuleResourceProvider implements WebdavService.Provider
{
    Path rootPath = Path.parse("/_webdav/");

    @Override
    public @Nullable Set<String> addChildren(@NotNull WebdavResource target, boolean isListing)
    {
        if (!AppProps.getInstance().isDevMode())
            return null;
        if (!target.getPath().equals(rootPath))
            return null;
        return Collections.singleton("@modules");
    }

    @Override
    public WebdavResource resolve(@NotNull WebdavResource parent, @NotNull String name)
    {
        if (!AppProps.getInstance().isDevMode())
            return null;
        if (!"@modules".equalsIgnoreCase(name))
            return null;
        if (!parent.getPath().equals(rootPath))
            return null;

        return new AllModuleResourcesRoot(parent, name);
    }



    private static class AllModuleResourcesRoot extends AbstractWebdavResourceCollection
    {
        AllModuleResourcesRoot(WebdavResource parent, String name)
        {
            super(parent.getPath(), name);
        }

        @Override
        public Collection<String> listNames()
        {
            List<String> ret = new ArrayList<>();
            for (Module module : ModuleLoader.getInstance().getModules())
            {
                boolean sourcePathMatched = module instanceof DefaultModule && ((DefaultModule)module).isSourcePathMatched();
                boolean enlistmentIdMatched = module instanceof DefaultModule && ((DefaultModule)module).isSourceEnlistmentIdMatched();
                // TODO  enlistmentId check seems to be broken (or changed behavior with gradle?)
                if (sourcePathMatched) // && enlistmentIdMatched)
                    ret.add(module.getName());
            }
	        ret.sort(String.CASE_INSENSITIVE_ORDER);
            return ret;
        }

        @Override
        public WebdavResource find(String name)
        {
            Module module = ModuleLoader.getInstance().getModule(name);
            if (null == module)
                return null;
            boolean sourcePathMatched = module instanceof DefaultModule && ((DefaultModule)module).isSourcePathMatched();
            boolean enlistmentIdMatched = module instanceof DefaultModule && ((DefaultModule)module).isSourceEnlistmentIdMatched();
            if (sourcePathMatched) // TODO  && enlistmentIdMatched)
            {
                File root = null;
                if (null != module.getSourcePath())
                    root = new File(module.getSourcePath());
/* UNDONE: a lot of resourcea are NOT under /resources/ need to use sourceRoot
                if (module instanceof DefaultModule)
                {
                    List<File> list = ((DefaultModule) module).getResourceDirectories();
                    if (list.size() == 1)
                        root = list.get(0);
                }
*/
                if (null != root)
                    return new _ModuleSourceResource(getPath().append(module.getName()), Path.emptyPath, root);
            }
            return null;
        }

        @Override
        public boolean shouldIndex()
        {
            return false;
        }

        @Override
        public boolean canRead(User user, boolean forRead)
        {
            return user.isPlatformDeveloper();
        }

        @Override
        public boolean canList(User user, boolean forRead)
        {
            return true;
        }

        @Override
        public boolean canWrite(User user, boolean forWrite)
        {
            return user.isPlatformDeveloper();
        }

        @Override
        public boolean canCreate(User user, boolean forCreate)
        {
            return false;
        }

        @Override
        public boolean canCreateCollection(User user, boolean forCreate)
        {
            return false;
        }

        @Override
        public boolean canDelete(User user, boolean forDelete)
        {
            return false;
        }

        @Override
        public boolean canDelete(User user, boolean forDelete, @Nullable List<String> message)
        {
            return false;
        }

        @Override
        public boolean canRename(User user, boolean forRename)
        {
            return false;
        }

        @Override
        public boolean exists()
        {
            return true;
        }

        @Override
        public boolean isCollection()
        {
            return true;
        }
    }


    static class _ModuleSourceResource extends FileSystemResource
    {
        final boolean _moduleRoot;
        final Path modulePath;
        final Path relativePath;

        _ModuleSourceResource(Path modulePath, Path relativePath, File file)
        {
            super(modulePath.append(relativePath));
            this.modulePath = modulePath;
            this.relativePath = relativePath;
            _files = Collections.singletonList(new FileInfo(FileUtil.getAbsoluteCaseSensitiveFile(file)));
            _moduleRoot = relativePath.size()==0;
        }

        @Override
        public String getName()
        {
            return super.getName();
        }

        @Override
        public String getContainerId()
        {
            return super.getContainerId();
        }

        @Override
        protected void setPolicy(SecurityPolicy policy)
        {
            super.setPolicy(policy);
        }

        @Override
        public boolean exists()
        {
            return super.exists();
        }

        @Override
        public boolean isCollection()
        {
            return super.isCollection();
        }

        @Override
        public boolean isFile()
        {
            return super.isFile();
        }

        @Override
        protected FileInfo getFileInfo()
        {
            return super.getFileInfo();
        }

        @Override
        public File getFile()
        {
            return super.getFile();
        }

        @Override
        public FileStream getFileStream(User user) throws IOException
        {
            return super.getFileStream(user);
        }

        @Override
        public InputStream getInputStream(User user) throws IOException
        {
            return super.getInputStream(user);
        }

        @Override
        public long copyFrom(User user, FileStream is) throws IOException
        {
            return super.copyFrom(user, is);
        }

        @Override
        public void moveFrom(User user, WebdavResource src) throws IOException, DavException
        {
            super.moveFrom(user, src);
        }

        @NotNull
        @Override
        public Collection<String> listNames()
        {
            return super.listNames();
        }

        @Override
        public Collection<WebdavResource> list()
        {
            return super.list();
        }

        @Override
        public WebdavResource find(String name)
        {
            File f = _files.get(0).getFile();
            File find = new File(f,name);
            return new _ModuleSourceResource(modulePath, relativePath.append(name), find);
        }

        @Override
        public long getCreated()
        {
            return super.getCreated();
        }

        @Override
        public long getLastModified()
        {
            return super.getLastModified();
        }

        @Override
        public long getContentLength()
        {
            return super.getContentLength();
        }

        @Override
        public boolean canRead(User user, boolean forRead)
        {
            return user.isPlatformDeveloper();
        }

        // TODO distinguish editable/reloadable in the module editor UI
        @Override
        public boolean canWrite(User user, boolean forWrite)
        {
            return !_moduleRoot && user.isPlatformDeveloper() && isReloadableResource();
        }

        @Override
        public boolean canCreate(User user, boolean forCreate)
        {
            return canWrite(user, forCreate);
        }

        @Override
        public boolean canCreateCollection(User user, boolean forCreate)
        {
            return user.isPlatformDeveloper();
        }

        @Override
        public boolean canDelete(User user, boolean forDelete, @Nullable List<String> message)
        {
            return !_moduleRoot && user.isPlatformDeveloper();
        }

        @Override
        public boolean canRename(User user, boolean forRename)
        {
            return !_moduleRoot && user.isPlatformDeveloper();
        }

        @Override
        public boolean canList(User user, boolean forRead)
        {
            return user.isPlatformDeveloper();
        }

        @Override
        public boolean delete(User user)
        {
            return super.delete(user);
        }

        @NotNull
        @Override
        public Collection<WebdavResolver.History> getHistory()
        {
            return Collections.emptyList();
        }

        @Override
        public User getCreatedBy()
        {
            return super.getCreatedBy();
        }

        @Override
        public String getDescription()
        {
            return super.getDescription();
        }

        @Override
        public User getModifiedBy()
        {
            return super.getModifiedBy();
        }

        @NotNull
        @Override
        public Collection<NavTree> getActions(User user)
        {
            return Collections.emptyList();
        }

        @Override
        public boolean shouldIndex()
        {
            return false;
        }

        @Override
        public Map<String, String> getCustomProperties(User user)
        {
            Map<String,String> map = new TreeMap<>();
            if (AppProps.getInstance().isDevMode())
            {
                File f = getFile();
                if (null != f)
                    map.put("sourcePath", f.getAbsolutePath());
            }
            return map;
        }

        @Override
        public void notify(ContainerUser context, String message)
        {
        }

        @Override
        protected List<ExpData> getExpData()
        {
            return null;
        }


        // if path doesn't start with one of these, it is not editable
        // TODO verify this list
        static private List<Path> writableResourceDirectories = Arrays.asList(
            new Path("resources", "etls"),
            new Path("resources", "olap"),
            new Path("resources", "pipeline"),
            new Path("resources", "queries"),
            new Path("resources", "reports"),
            new Path("resources", "scripts"),
            new Path("resources", "views"),
            new Path("resources", "web"),
            new Path("etls"),
            new Path("olap"),
            new Path("pipeline"),
            new Path("queries"),
            new Path("reports"),
            new Path("scripts"),
            new Path("views"),
            new Path("web"),
            new Path("webapp")
        );

        public boolean isReloadableResource()
        {
            if (writableResourceDirectories.stream().filter(p -> relativePath.startsWith(p)).findAny().isEmpty())
                return false;
            return true;
        }
    }
}
