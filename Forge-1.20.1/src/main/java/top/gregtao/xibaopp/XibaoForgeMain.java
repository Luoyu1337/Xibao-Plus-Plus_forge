package top.gregtao.xibaopp;

import net.minecraftforge.fml.common.Mod;
import net.minecraftforge.fml.event.lifecycle.FMLClientSetupEvent;
import net.minecraftforge.eventbus.api.IEventBus;
import net.minecraftforge.fml.javafmlmod.FMLJavaModLoadingContext;

@Mod("xibaopp")
public class XibaoForgeMain {
    public XibaoForgeMain() {
        IEventBus bus = FMLJavaModLoadingContext.get().getModEventBus();
        bus.addListener(this::clientSetup);
    }

    private void clientSetup(final FMLClientSetupEvent event) {
        // 客户端注册（声音、GUI、渲染器等）
    }
}
