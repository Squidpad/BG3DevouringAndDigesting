# exports each selected object into its own file

import bpy
import os
import shutil
from object_print3d_utils import mesh_helpers  # type: ignore
from uuid import uuid4

#
# edit these variables
#
no_export = False
no_delete = False

use_volume_step = False
# makes the graph a bit straighter (see screenshot)
use_step_decrease = True
outputdir = "output"
outputfiledir = "data"
shapekey_name = "VORE"
# key : name of mesh, should be the same as in _merged
# Enabled : if false, skips this belly entirely
# BelliesCount : how many bellies to make
# BelliesStep : volume steps per slider
# Armature : name of this belly's armature in blender file
# File : Should be SP + Race + Body Shape + Belly/Cock + i + .GR2
# Slot : DragonbornTop for non-dragonborn bellies, something else for dragonborn or cocks
# Material : uuid of the body/cock material for this race / body type / body shape. Find it in game files
# Also add a correct function in exportone() for prediciting volume
# 1 avarage human ~ 0.14 volume (visually)
body = {
    "HUM_F_NKD_Body_A_Mesh": {
        "Enabled": True,
        "BelliesCount": 72,
        "BelliesStep": 0.02,
        "BelliesSliderStep": 0.02,
        "Armature": "Armature1",
        "File": "SP_HUM_F_Belly_#.GR2",
        "Slot": "DragonbornTop",
        "Material": "5e46e917-0c94-44ae-a41e-96428aa5ea32",
    },
    "HUM_FS_NKD_Body_A_Mesh": {
        "Enabled": False,
        "BelliesCount": 72,
        "BelliesStep": 0.02,
        "BelliesSliderStep": 0.02,
        "Armature": "Armature",
        "File": "SP_HUM_FS_Belly_#.GR2",
        "Slot": "DragonbornTop",
        "Material": "9106a412-4963-2147-914b-838fd337cf43",
    },
    "HUM_M_NKD_Body_A_Mesh": {
        "Enabled": False,
        "BelliesCount": 50,
        "BelliesStep": 0.02,
        "BelliesSliderStep": 0.02,
        "Armature": "Armature3",
        "File": "SP_HUM_M_Belly_#.GR2",
        "Slot": "DragonbornTop",
        "Material": "3fa84d0c-016b-65bd-3b16-fc7892eaa85d",
    },
    "HUM_MS_NKD_Body_A_Mesh": {
        "Enabled": False,
        "BelliesCount": 50,
        "BelliesStep": 0.02,
        "BelliesSliderStep": 0.02,
        "Armature": "Armature4",
        "File": "SP_HUM_MS_Belly_#.GR2",
        "Slot": "DragonbornTop",
        "Material": "ceff760d-6904-40bd-9a8d-8cf84993020f",
    },
    "DGB_F_NKD_Body_A_Mesh": {
        "Enabled": False,
        "BelliesCount": 50,
        "BelliesStep": 0.02,
        "BelliesSliderStep": 0.02,
        "Armature": "Armature7",
        "File": "SP_DGB_F_Belly_#.GR2",
        "Slot": "Beard",
        "Material": "9b45c363-a889-3b9f-9822-b3cd50c9b74a",
    },
    "DGB_M_NKD_Body_A_Mesh": {
        "Enabled": False,
        "BelliesCount": 50,
        "BelliesStep": 0.02,
        "BelliesSliderStep": 0.02,
        "Armature": "Armature8",
        "File": "SP_DGB_M_Belly_#.GR2",
        "Slot": "Beard",
        "Material": "7a5afaa4-7427-853d-c6b7-90454f383d0e",
    },
}

#
# do not edit these
#
volumes = []
folder = ""
datafolder = ""

s_vis = ""
s_cc = ""
s_bt = ""
s_at = ""

s_sli = ""
s_vol = ""

# get slider value by volume
# generate your bellies with use_volume_step set to False
# copy the data from the bottom of table.lua to an online function approximator (or whatever it's called)
# copy the function into another online tool that reverses x and y
# make a new function here for your bellies
# add it to exportone()
def HUM_FS_vol(y):
    x = (
        (
            (175771869075000000 * y**2 + 238527111140000 * y + 82871492567) ** 0.5
            / (3214849 * 3 ** (11 / 2))
            + ((10000 * y - 18) / 5379 + 3089642 / 260402769) / 6
            - 137228404312 / 113457226050531
        )
        ** (1 / 3)
        - 2393225
        / (
            2343624921
            * (
                (175771869075000000 * y**2 + 238527111140000 * y + 82871492567) ** 0.5
                / (3214849 * 3 ** (11 / 2))
                + ((10000 * y - 18) / 5379 + 3089642 / 260402769) / 6
                - 137228404312 / 113457226050531
            )
            ** (1 / 3)
        )
        - 5158 / 48411
    )
    return x


def vol_to_breakpoint(vol : float) -> int:
    return round(vol * 1000)


def copy_attribute(source, target, mod):
    new_mod = target.modifiers.new(name=mod.name, type=mod.type)
    for attr in dir(mod):
        # We need to avoid copying read-only and special attributes
        if (
            not attr.startswith("__")
            and not attr.endswith("rna_type")
            and hasattr(new_mod, attr)
        ):
            try:
                setattr(new_mod, attr, getattr(mod, attr))
            except AttributeError:
                # Some attributes might not be writable or may not exist on the new modifier,
                # so we handle this with a try-except block to skip them.
                pass


def hideother(objname, armname):
    unhide = set()

    unhide.add(objname)
    unhide.add(armname)

    for obj in bpy.data.objects:
        if obj.name not in unhide:
            obj.hide_set(True)
        else:
            obj.hide_set(False)


def hideall():
    for obj in bpy.data.objects:
        obj.hide_set(True)


def write_one(name: str, meshName: str, slot: str, volume: float, i: int, material : str):
    global s_vis
    global s_cc
    global s_bt
    global s_at

    splitName = name.split(".")[0]

    mergedUUID = uuid4()
    visualsUUID = uuid4()
    s_vis += f"""        			<!-- {i} -->
                <node id="Resource">
                    <attribute id="AttachBone" type="FixedString" value="" />
                    <attribute id="AttachmentSkeletonResource" type="FixedString" value="" />
                    <attribute id="BlueprintInstanceResourceID" type="FixedString" value="" />
                    <attribute id="BoundsMax" type="fvec3" value="0.04660766 1.031223 0.05886364" />
                    <attribute id="BoundsMin" type="fvec3" value="-0.04640537 0.8961504 -0.1221507" />
                    <attribute id="ClothColliderResourceID" type="FixedString" value="" />
                    <attribute id="HairPresetResourceId" type="FixedString" value="" />
                    <attribute id="HairType" type="uint8" value="0" />
                    <attribute id="ID" type="FixedString" value="{mergedUUID}" />
                    <attribute id="MaterialType" type="uint8" value="0" />
                    <attribute id="Name" type="LSString" value="{splitName}" />
                    <attribute id="NeedsSkeletonRemap" type="bool" value="False" />
                    <attribute id="RemapperSlotId" type="FixedString" value="" />
                    <attribute id="ScalpMaterialId" type="FixedString" value="" />
                    <attribute id="SkeletonResource" type="FixedString" value="" />
                    <attribute id="SkeletonSlot" type="FixedString" value="" />
                    <attribute id="Slot" type="FixedString" value="{slot}" />
                    <attribute id="SoftbodyResourceID" type="FixedString" value="" />
                    <attribute id="SourceFile" type="LSString" value="Generated/Public/DevouringAndDigesting/Assets/Characters/Humans/{name}" />
                    <attribute id="SupportsVertexColorMask" type="bool" value="False" />
                    <attribute id="Template" type="FixedString" value="Generated/Public/DevouringAndDigesting/Assets/Characters/Humans/{splitName}.Dummy_Root.0" />
                    <attribute id="_OriginalFileVersion_" type="int64" value="144115207403209033" />
                    <children>
                        <node id="AnimationWaterfall">
                            <attribute id="Object" type="FixedString" value="" />
                        </node>
                        <node id="Base" />
                        <node id="ClothProxyMapping" />
                        <node id="Objects">
                            <attribute id="LOD" type="uint8" value="0" />
                            <attribute id="MaterialID" type="FixedString" value="{material}" />
                            <attribute id="ObjectID" type="FixedString" value="{splitName}.{meshName}.0" />
                        </node>
                    </children>
                </node>\n"""

    s_cc += f"""				<!-- {i} -->
            <node id="CharacterCreationSharedVisual"> 
                <attribute id="DisplayName" type="TranslatedString" handle="h3e21526aga300g458cgb359gff46cedfb300" version="1" />
                <attribute id="SlotName" type="FixedString" value="{slot}" />
                <attribute id="UUID" type="guid" value="{visualsUUID}" />
                <attribute id="VisualResource" type="guid" value="{mergedUUID}" />
                <children>
                    <node id="Tags">
                    </node>
                </children>
            </node>\n"""

    s_bt += f'                [{str(vol_to_breakpoint(volume))}] = "{visualsUUID}",\n'
    s_at += f'    ["{visualsUUID}"] = true,\n'


def exportone(objname):
    global s_sli
    global s_vol

    print("Exporting " + objname)

    obj = bpy.data.objects.get(objname)
    if obj is None:
        print("Skipping " + objname)
        return

    belliesToMake = body[objname]["BelliesCount"]
    onestep = body[objname]["BelliesStep"]
    onesliderstep = body[objname]["BelliesSliderStep"]
    filename = body[objname]["File"]
    shape_key = None
    currentstep = 0

    # get and initialize the shape key
    if obj.data.shape_keys and shapekey_name in obj.data.shape_keys.key_blocks:
        shape_key = obj.data.shape_keys.key_blocks[shapekey_name]
        shape_key.value = 0
        shape_key.slider_max = 10
    else:
        print(objname + " has no shapekey " + shapekey_name)
        return

    for i in range(1, belliesToMake + 1):
        currentstep = 0
        
        if use_volume_step:
            if objname == "HUM_FS_NKD_Body_A_Mesh":
                currentstep = HUM_FS_vol(onestep * i)
            else:
                currentstep = HUM_FS_vol(onestep * i)
        elif use_step_decrease:
            currentstep = (onesliderstep * i)**(1/1.6) - onesliderstep **(1/1.6) / (i + 1)
        else:
            currentstep = onesliderstep * i
            
        shape_key.value = currentstep

        name = filename.replace("#", str(i))

        bpy.context.view_layer.objects.active = obj
        bpy.ops.object.select_all(action="DESELECT")
        hideother(objname, body[objname]["Armature"])
        obj.select_set(True)

        bpy.ops.object.duplicate_move()
        obj.select_set(False)
        obj.hide_set(True)
        dupe = bpy.context.active_object
        bpy.ops.object.convert(target="MESH")
        copy_attribute(obj, dupe, obj.modifiers["Armature"])
        bm = mesh_helpers.bmesh_copy_from_object(dupe, apply_modifiers=True)
        volume = bm.calc_volume()
        bm.free()

        print(name + " " + str(shape_key.value) + " " + str(volume))

        fullpath = folder + "\\" + name
        fullfolder = folder + "\\"

        print(fullpath)
        print(fullfolder)

        if not no_export:
            bpy.ops.export_scene.dos2de_collada(
                filepath=fullpath, filename=name, directory=fullfolder
            )

        s_vol += str(volume) + " "
        s_sli += str(shape_key.value) + " "

        write_one(name, objname, body[objname]["Slot"], volume, i, body[objname]["Material"])

        if not no_delete:
            bpy.ops.object.delete()
        else:
            dupe.hide_set(True)

        shape_key.value = 0
        shape_key.slider_max = 10


def writefiles():
    f1 = open(f"{datafolder}/_merged.xml", "w")
    f1.write(s_vis)
    f1.close()
    f2 = open(f"{datafolder}/CharacterCreationSharedVisuals.xml", "w")
    f2.write(s_cc)
    f2.close()
    f3 = open(f"{datafolder}/table.lua", "w")
    f3.write("local x = {\n\n")
    f3.write(s_bt)
    f3.write("\n\n\n")
    f3.write(s_at)
    f3.write("\n\n\n}")
    f3.write(s_sli)
    f3.write("\n\n")
    f3.write(s_vol)
    f3.close()


def main():
    global folder
    global datafolder
    global s_vis
    global s_cc
    global s_bt
    global s_at
    hideall()
    folder = os.path.dirname(bpy.data.filepath) + "\\" + outputdir
    if not os.path.exists(folder):
        os.makedirs(folder)

    datafolder = os.path.dirname(bpy.data.filepath) + "\\" + outputfiledir
    if not os.path.exists(datafolder):
        os.makedirs(datafolder)

    for filename in os.listdir(folder):
        file_path = os.path.join(folder, filename)
        try:
            if os.path.isfile(file_path) or os.path.islink(file_path):
                os.unlink(file_path)
            elif os.path.isdir(file_path):
                shutil.rmtree(file_path)
        except Exception as e:
            print("Failed to delete %s. Reason: %s" % (file_path, e))

    for objname in body:
        print(objname)
        if body[objname]["Enabled"]:
            exportone(objname)
            s_vis += "\n\n\n"
            s_cc += "\n\n\n"
            s_bt += "\n\n\n"
            s_at += "\n\n\n"

    writefiles()
    

main()
