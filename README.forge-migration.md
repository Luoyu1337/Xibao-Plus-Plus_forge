说明：此补丁为 Forge 移植骨架。使用方法：
1) 在本地仓库根运行：
   git checkout -b forge-1.20.1-port
   # 将本目录下的 Forge-1.20.1 文件复制或直接把这些文件添加到仓库
2) 根据注释替换 build.gradle 中的 ForgeGradle/mappings/forge 具体版本号
3) 在项目根运行 gradle wrapper（如果未包含 wrapper）：
   gradle wrapper --gradle-version 8.3
4) 运行 ./gradlew :Forge-1.20.1:build

注意：mixins 需要把目标名从 Yarn 映射调整为 Mojmap 名称；Fabric API 依赖需替换或实现兼容逻辑。
