#include <ai.h>

#include <cstdio>
#include <cstring>
#include <iostream>

int main(int argc, char **argv)
{
    AiMsgSetConsoleFlags(nullptr, AI_LOG_ALL);
    AiBegin();

    AiSceneLoad(nullptr, "scene.ass", nullptr);
    AtUniverse *proc_universe = AiUniverse();
    AtNode *proc = AiNode(proc_universe, "usd", "usd_proc");
    AiNodeSetStr(proc, "filename", "nested_proc.usda");

    AiProceduralViewport(proc, nullptr, AI_PROC_POLYGONS);

    AtNode *proc2 = AiNode(proc_universe, "usd", "usd_proc2");
    AiNodeSetStr(proc2, "filename", "cube.usda");

    AiProceduralViewport(proc2, nullptr, AI_PROC_POLYGONS);

    AiUniverseDestroy(proc_universe);
    AiRender(nullptr);

    AiEnd();
    return 0;
}
