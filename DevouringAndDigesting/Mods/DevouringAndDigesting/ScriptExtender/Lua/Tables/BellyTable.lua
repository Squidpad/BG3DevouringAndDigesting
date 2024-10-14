---all bellies (used for removing viusal overrides)
---@type table<GUIDSTRING, boolean>
AllBellies = {}

---@type table<string, table<integer, GUIDSTRING>>
BellySets = {
    Human1 = {
        [5] = "e0d8e3d1-c34a-4539-a6f7-8ed2ae4d2374",
        [14] = "b69a552c-bfc6-434f-85a3-6b514755d77c",
        [25] = "50396633-f06d-4b8f-992f-ab06b4e9488c",
        [38] = "87a9ac08-8761-4895-af22-8f02ac6129a5",
        [53] = "e91907e8-55a0-4be9-8c96-ba9289f4fcf6",
        [70] = "f34ef939-f289-4e47-9c80-9a867b229402",
        [88] = "f5fbfd71-2541-4b20-b04b-c3d3650f9a80",
        [109] = "ebf1ea92-ad33-4c9e-9edc-34fbf265d938",
        [131] = "e4c0cedd-5e21-4d32-a3ea-8d21e246e2ef",
        [154] = "be7d596e-04b0-4571-b6a2-dd5639d55447",
        [179] = "d603c761-5eae-4e2a-828b-427bc273586c",
        [206] = "7b1a218c-a0f8-4b55-9546-e62b54bb20d7",
        [234] = "635e6ab9-0aba-458d-b1c4-bfa510016b8d",
        [264] = "1cc78903-4c8b-4912-886e-c546b50b60bb",
        [295] = "93ec8e00-c791-44bb-9da8-82e2a567b76e",
        [328] = "d77586f6-55d9-4a2f-a1c0-44e76f0a134d",
        [362] = "a96c75c4-6f5e-418d-b9b3-9a7abe2887d6",
        [398] = "097b06a3-562b-4ceb-afe5-a9f7032b7e3f",
        [435] = "ecf42b9b-6a67-4d9a-b73f-a4fbcacb3a8f",
        [474] = "bccd5300-12f3-4789-9bf3-48eecec15f12",
        [513] = "9f9c3b11-c8ca-4055-a39f-82392f254c2a",
        [555] = "8291ac94-e2fb-4fe9-89ad-bc0db574a024",
        [598] = "e3f91c22-1719-4554-a2f8-7b0dd5549ff2",
        [642] = "172b1c64-634c-4d65-a2cc-b2b7ba9ea1d1",
        [687] = "328f6a62-5602-4d4d-a82c-22dd9ea9fe7d",
        [734] = "9ce2bdf7-8b3f-4f55-9546-06fe3da5a327",
        [782] = "74a0ab60-7c57-495f-82ad-81ab3e29bd96",
        [832] = "cf593a57-c2b3-4a74-97f3-37a5c1bb59ec",
        [883] = "47b35bec-298f-4d06-8bff-2e6d1a344a73",
        [935] = "4ce28819-9253-4cdb-bdd6-f3e9ee6d1d97",
        [988] = "63b62164-68e5-48f5-8d13-ff6a5ae4d264",
        [1043] = "5c03126e-6bab-42f2-a156-de9d496e8af5",
        [1099] = "a1533f2b-9a74-4a65-a936-938e4de3ebe3",
        [1157] = "c4e9fbe5-7c3b-478d-a9f4-f5428c34b802",
        [1216] = "db5dbc69-39e8-4f43-91cf-1a63332ebb0a",
        [1276] = "e73c8acb-4d88-46f0-8b91-0cff9842a441",
        [1337] = "5a51c715-ca3a-4422-b1d2-bd8bde537ae0",
        [1400] = "a6b75167-6d4a-4663-b343-fe264a47dcd9",
        [1464] = "c1278907-06e9-4500-b827-d6302c28595a",
        [1529] = "67d09988-345a-4e38-9f44-8b636c5e4cdf",
        [1595] = "a61b17bd-e63a-4759-ac31-8f81625923cd",
        [1663] = "fa965ddd-4c80-4f04-9e6f-edfae67cdd2f",
        [1732] = "28f2c855-6f8b-4426-9353-0227e74f768a",
        [1802] = "8fc1f0dc-55aa-49fe-8665-e032a512bd9f",
        [1874] = "55dcdc90-6aec-44f0-b737-30a0f8682266",
        [1946] = "8ade4cbd-9f97-47f0-a15b-fd35d06bcccd",
        [2020] = "4f17d5cc-175c-41ae-87bb-9eb5b159858e",
        [2095] = "02f6d61c-a7d2-4d28-add0-f9262242afc6",
        [2172] = "2339fd4b-ad6f-4281-af1d-b6d7a9f7ab20",
        [2249] = "1bede670-6174-423c-86bc-6f9b806e3961",
        [2328] = "9966e11c-0d6a-4144-9b17-e465e6870ef0",
        [2408] = "a8c35b92-5848-40d5-b32a-523731f93489",
        [2490] = "43904d3c-6368-452d-9f9f-6f1d1886681d",
        [2572] = "20c3c9f2-19f0-48bd-9bea-4f7bd3d86c30",
        [2656] = "bbe0f00c-f618-4ea1-be95-6b221e790a2e",
        [2741] = "5ac084b7-ed8e-4339-b8b3-9c6e676e1d5b",
        [2827] = "e229b4d5-9738-490a-8c32-f3e279cc6777",
        [2915] = "cf1c206a-7eaf-48a5-8021-7fdb339047a9",
        [3003] = "87c96b06-5f74-4cfd-b3e1-a490e1cfdc25",
        [3093] = "dd6f1d9b-d05d-4c17-bc03-6c2fc470518b",
        [3184] = "2e206e6c-0b13-4693-a0bb-8c476d795ef0",
        [3276] = "76f44f03-42d9-44e8-af5d-c3c51580b986",
        [3369] = "faee04d2-529c-4aff-b828-be21a1d735d2",
        [3464] = "e0af0206-bea4-4b37-a89f-9b744199ab73",
        [3559] = "17c6877f-1c30-4b80-b513-3fea35ef83f0",
        [3656] = "806e7be5-207a-4657-a5f5-3241fb18404e",
        [3754] = "92e32cb1-fbe7-40f0-827e-93798e0a60ff",
        [3854] = "8a42ddd7-22dd-46a9-a5d2-cdd6e4f1d01c",
        [3954] = "7496e46a-4a87-4d22-9ae7-70a9159da659",
        [4056] = "8b0ca808-0f9f-45f2-8968-8a631e37f944",
        [4158] = "97b65fcf-de9f-430a-8ed8-e36b4132ccbc",
        [4262] = "e3e3c516-93d9-4a70-a697-a7238ac90173",
    },
    Human2 = {
        [6] = "dc225e58-d17e-40d0-8ba5-cb12df706f63",
        [14] = "57dbab5e-d825-4e31-831b-7a16040f616d",
        [25] = "a8b0b849-81f3-4a2a-94db-d41d07dd08f5",
        [38] = "aa90c607-7bca-483b-90cc-9f48afe88aa8",
        [52] = "bbeb4cfd-eb4b-423a-92a1-77c12b2de368",
        [69] = "8e99ff44-f232-48bb-aaf7-aa1e34aa50a3",
        [86] = "20030e8c-1dde-4c86-b392-94a5a0c3d7e0",
        [106] = "1212742f-0798-4324-bf42-92aa683f16dc",
        [126] = "074f69e6-d834-4a7e-b34c-5fa9ceb297cb",
        [149] = "8a2fc258-2a6f-4aec-a8fe-9e96beafbf93",
        [172] = "497a5887-99cc-41e4-862f-0eba77960768",
        [198] = "e2ea3a42-d788-4970-bc82-9d8c16699046",
        [224] = "432135f6-0475-4f90-b80e-fd836f055b37",
        [252] = "2ec9eab8-4290-45ab-934c-190badb57837",
        [281] = "aa3f8426-12e0-4505-b5e7-04fd94a693d7",
        [312] = "8bde8673-27f2-41f1-a620-f2d8d424c74b",
        [344] = "99ac24e7-3b65-4391-82e1-61ad57a28ae9",
        [377] = "9efc161d-75d4-4cfd-a663-f3a544edae45",
        [412] = "798bb0e8-8233-4a47-9ad8-77381093a569",
        [448] = "e4e8234b-4f64-4697-be3d-9b09e123c553",
        [485] = "642c31aa-c0eb-4bd9-85af-9f281cc62385",
        [524] = "34c5ccee-5852-4983-ac54-7178d293b030",
        [563] = "bb8b9866-1670-4313-b98f-74d9abdf059d",
        [604] = "1a8c6f4d-06bb-46b0-a63d-6ccfeecc6319",
        [647] = "49c41900-66db-4d61-b0ec-29eca247a1fa",
        [690] = "6e7b37f3-c3ee-4b60-bd8f-e5e5080ae8a2",
        [735] = "2c930972-9b78-416a-80b1-9faf164a1602",
        [781] = "527df719-25b0-4ea9-9b54-5b2f0edcb5dc",
        [828] = "e45cd065-6c66-4839-9e76-1a2e07eeac18",
        [876] = "6814bafe-3def-45bd-af9b-5451eef16e17",
        [926] = "1ba9d8da-52ae-446a-9d2e-3846f62b1aad",
        [977] = "10236cf2-924b-4c90-a082-65b25f68b729",
        [1029] = "670c3e94-bac1-4900-a73e-cb3b871c5c86",
        [1082] = "75c6f0ec-d8b2-41fa-9f76-8141fe44fc03",
        [1136] = "26a3652a-3a49-46cc-bf07-48cca67472ff",
        [1192] = "64efe776-4f68-4c06-af50-1026ed06980a",
        [1249] = "c43e1561-aaa1-4b71-aee7-adae638ac579",
        [1307] = "2a102411-0ca0-4fdc-92c6-eebdd9ba142a",
        [1366] = "2db52abe-ef6e-46da-b479-de28c78eae28",
        [1426] = "7c6996cb-3202-4b34-a6ff-60db1d34232d",
        [1487] = "6a884df8-212d-42d2-bb68-1a173ab99d66",
        [1550] = "402a2c9e-3e1c-4e55-83a6-d951ba82c35d",
        [1614] = "d46d9faa-b883-4aff-930f-137d309a08cf",
        [1678] = "a7bcd280-428c-486c-89e6-95dcd17eb3bd",
        [1744] = "7ecb5559-6fb2-42f4-b4ce-1d4bf8295c1f",
        [1812] = "1f7969dc-9ce1-45b9-b1b6-bb8690a9b5ce",
        [1880] = "49c98106-a5df-41ba-a53c-369785c6652b",
        [1949] = "25f92b79-e009-4a31-8d15-f8a98c415355",
        [2020] = "5da167c6-5b71-4a50-8e00-7e1cb4e5c0e9",
        [2091] = "04b8ab30-29b9-4315-a58d-c5db869606d1",
    },
    Human3 = {
        [5] = "56afecdc-5915-41a0-b8e2-96a450e7fe50",
        [16] = "f88487f9-59ac-45a9-814f-ebc682a114dc",
        [28] = "4f001d8b-75a0-4b5d-a624-63425cd65a6c",
        [42] = "5585603f-7b21-42c7-8fbc-b8f72013836c",
        [59] = "db69cb71-1546-43d1-9eb6-6717644b834d",
        [76] = "4160db26-c81f-4e7c-8cd2-05e105e837d6",
        [96] = "831665bf-614a-4b8d-af7a-ec350b8d7d64",
        [117] = "651b9efe-983e-475a-a84b-bc6617392033",
        [139] = "957cd438-75bd-44b3-953e-6b9a1aa9ff39",
        [163] = "f0ff7a3c-9e04-4b80-8d7f-60361225e813",
        [189] = "ab0b3ff9-f5b8-4c9d-8da8-3bfac07d22f7",
        [216] = "c05bb1a4-a212-473d-9c31-2affdc5bc3e3",
        [244] = "7ab4ff66-394a-4777-aec2-dbb07a5610d1",
        [274] = "29e864b2-87a2-44a9-be42-cb455e047573",
        [305] = "3411a2ac-69d0-48b8-80b0-85cca54ad8a9",
        [337] = "64da317b-0399-4f68-881a-8f627f96b4a0",
        [371] = "22f890e4-262d-4dec-a0ff-4568b70a66ab",
        [406] = "9335ce3f-d613-4635-ab0f-752c703095f0",
        [442] = "1b61f4e6-2cb3-4508-8d87-2be1f85dce87",
        [480] = "67c7083d-eac3-46f5-8d03-a205ff8b8379",
        [519] = "4975cb30-4875-496b-9cec-ba6887fd3dcc",
        [560] = "622a9a3c-e208-43fa-9e67-439df353e770",
        [601] = "e61aef52-f15f-46ae-8459-4028e510eecb",
        [644] = "9f85cd90-2d27-4197-8458-86729240418a",
        [688] = "a1486419-8bae-463d-bcee-cc21cc91b1be",
        [734] = "3688f5b6-880b-4683-86a1-518c83741007",
        [780] = "1632c6fc-9501-40a4-81bf-2231133820a7",
        [828] = "b8144882-8edd-48a4-a68f-b470fa19bfe0",
        [877] = "6a4e1f65-11ff-4f82-98e7-06cd622f0cf8",
        [928] = "d2905085-2f66-4ba3-a41a-07d7a6142b42",
        [979] = "48f8ae9c-e022-46b0-9914-c905e7f85bd4",
        [1032] = "60519fc2-dbcf-44e7-a7df-3e82cd0bca19",
        [1086] = "2cddb563-7c3f-4fe7-b1b9-0d0cf7b6a1bc",
        [1141] = "f10841f9-330a-405f-b640-613b3ec0a5a4",
        [1197] = "6a17e544-2a0e-4ad9-8063-91e278a1b1f1",
        [1255] = "a55387eb-4fa8-430a-950a-843e4492286a",
        [1313] = "59eb8f94-810b-41ad-a67a-354a757bd2c6",
        [1373] = "90c4028f-bad2-45ae-94d8-fc6600695877",
        [1434] = "1399aec3-582c-47ed-9294-b544d389bde7",
        [1497] = "2414570a-911c-4f35-866e-bfc1eaae768b",
        [1560] = "05fb3b74-a81d-42f2-a312-5206251d4066",
        [1624] = "de00df2a-24ed-4fb7-9196-97a2ec9ad2d8",
        [1690] = "01be1a63-c97c-4586-a13a-ec1a00882f42",
        [1757] = "8eb71ea3-20fd-48c7-83c7-9ba51d052286",
        [1825] = "fb4aef93-cb74-46e9-b59d-8262bf724e02",
        [1894] = "07dc2d14-440b-4d72-a4b6-676912dd7ec7",
        [1964] = "6f2bf461-9c9a-4e38-9410-8e8edaceb6e8",
        [2035] = "f3c95d63-1af7-4687-bbdb-f9143313fb6c",
        [2108] = "4ad9f0b6-aa66-4028-8fb9-43856d765e2a",
        [2181] = "b02ea990-a0a1-4a96-bee9-57454c3a35d2",
        [2256] = "4202688f-f6c5-46fb-92fd-6c5ec9149ac0",
        [2332] = "b518d2a4-8d55-4d6b-b693-96c6af77e7c0",
        [2409] = "369e145c-d014-4c7e-a81b-5c40b166566d",
        [2487] = "801900b5-6a25-4a1b-86f3-93613e74de4c",
        [2566] = "f118e3d5-6d7e-4f79-9d35-ab680df22b3b",
        [2646] = "d74bf8b4-dce0-40c9-a7c5-8e5cf9dd5012",
        [2728] = "75f8b698-5dea-42e1-a3b3-430c4dbf2d14",
        [2810] = "0fd2d437-1f2a-4312-a026-637ea381874e",
        [2893] = "51ab86f2-59fd-4b3f-ba13-25cbd6dceb2f",
        [2978] = "ce572b06-b003-4957-a8f3-647b25968ddb",
        [3064] = "91a92163-f156-4531-9266-c065a7238d32",
        [3151] = "976a9a3f-1302-4894-a12d-ff7afd772f43",
        [3238] = "bcb2e70a-364b-44b5-b9f0-57389438dff4",
        [3327] = "6fea9006-3cfc-48df-86df-cd309011cb84",
        [3417] = "90b7678f-60bf-499c-9779-7f305601cb20",
        [3509] = "07c45aa9-e0c1-4d80-a635-18bcf04d182b",
        [3601] = "fc82e405-e024-45f1-97b3-1397b104867c",
        [3694] = "e440337e-676b-4f77-a104-480608df2bf8",
        [3788] = "d4087ca8-919f-4c22-828f-e76cc738f44f",
        [3884] = "9e18f181-5818-40b8-ad6c-79d4bb55d222",
        [3980] = "8536b126-baa5-44b5-8bf2-e0cf943bdce1",
        [4078] = "2720d75c-e58e-4f8e-9729-17fc8c7f1b6d",
    },
    Human4 = {
        [6] = "f774bc10-d2f2-4d47-8c25-9626471aa2bb",
        [17] = "b997fa76-589e-40fa-b514-da124ea38402",
        [31] = "930b320a-487d-4e8d-bcd5-641a070691b2",
        [46] = "036624cc-d3e5-47d4-a863-42f7393a7163",
        [64] = "bea3aa51-c674-4f2a-ac85-8f3dfc8ee8be",
        [83] = "6a2623b2-107d-4e27-aef1-41693f3cf151",
        [103] = "8a9bd76d-7713-4155-8255-ff124ca7baeb",
        [126] = "9bdb340b-506d-4641-b300-7ec4fc278a2b",
        [150] = "611b63d1-51c7-4fec-873d-bef3c143f88e",
        [175] = "2a17caa2-042c-4910-9073-27940ea94bbb",
        [202] = "a6848a13-a520-4a4f-bbe1-bb6b301a3fc3",
        [230] = "1f61f7a0-b650-48a2-9a1d-460f27202b07",
        [260] = "a0c7e846-634c-4423-9b99-3fb8629ba173",
        [292] = "809b88ce-0891-4ea6-9c01-5f4e7dfc589d",
        [325] = "ca4a4f62-7dd5-4276-a52a-f01cd5861626",
        [359] = "28e92f13-537d-4ff5-a41d-0e1ba3efc4d9",
        [395] = "f49342c0-3292-4812-963e-f2a2e90dffed",
        [432] = "f269d0ac-a9a1-4e90-9984-118f28c85779",
        [470] = "55ac02b2-382e-4cd5-97ac-32abc35e70d4",
        [510] = "0184813f-72d0-44fc-b32e-fb0f99a8a00a",
        [551] = "90d5d02e-665e-4d04-a48c-2dfbd2dc1398",
        [593] = "8a65c7f4-aaab-4d15-810b-a8b0698e17c4",
        [637] = "193f18ea-9729-4d8c-b9d2-e87e0054b672",
        [682] = "0b7c65af-fd7d-4cd0-9f01-ec6b275d7288",
        [729] = "34f4dc2b-b6a9-45a4-81bb-e2ad503c27a9",
        [777] = "112f45c9-050e-44fe-88ae-1ad7d62b3aeb",
        [826] = "fce033db-917e-4511-af2f-8e6c33aaf223",
        [876] = "cf2caa36-e45e-48b0-9564-773808b92520",
        [928] = "d7e06282-381c-402d-91dc-a70756b9f7ea",
        [981] = "7a225e23-a63d-456d-ba07-e3d59c2067f9",
        [1035] = "7b06342b-773d-4822-80f2-ef71693b8cf8",
        [1091] = "399fbabc-0d00-4649-beca-66b8f740d8b9",
        [1147] = "95edab6f-8319-4eb8-a3b7-f7b21385c5ef",
        [1205] = "a7601930-7c11-4073-b416-f06cd0de108a",
        [1264] = "774dec92-7453-4e64-af7e-426ec72cfb09",
        [1325] = "7b830f8f-49c0-4748-875c-220b4988897d",
        [1387] = "4b386dc0-4cbb-4143-b6bb-bff71248b6be",
        [1450] = "ddf4a728-e7de-4185-ba17-d22dead81f33",
        [1514] = "7b61cb2d-e043-4cd9-9e3e-cc0f5f4b2a20",
        [1579] = "33162a92-e801-4222-a473-a91371d512e3",
        [1646] = "807001f9-b0d4-41da-b11d-17e26a7f25e1",
        [1713] = "0b18af57-d6b5-47c8-9c65-d2109601f45d",
        [1782] = "3781720e-bc52-4a85-955a-b8296f181b4e",
        [1853] = "50e67e7f-b4b7-4107-aaa0-2cbec1d71c93",
        [1924] = "20807c27-feee-4704-b1fe-6c5b4a6c2181",
        [1996] = "106d6e6f-a880-425f-8610-ef9756c89de2",
        [2070] = "88e4cd4f-d948-4cd4-9160-98b55ec43dc3",
        [2145] = "1f6b04d5-7cbd-4b8d-b98c-ce9e1d91b735",
        [2221] = "976196f7-17ff-4d57-867a-f7cc75a448bd",
        [2299] = "655fb494-2756-4b5a-afcd-d06ca7c621e3",
    },
    Dragonborn1 = {
        [2] = "730357d0-3785-4a72-bff7-06479459f4b1",
        [10] = "c848f027-e62f-4f19-9a51-bb7975b2442a",
        [20] = "fb72907c-0f9d-4a8f-bb2a-811af78c38a6",
        [32] = "0fdc5bc9-cfc8-47c1-998d-48c5fa14b8fe",
        [46] = "176e840a-e53d-471c-b9ff-8fa21ca41150",
        [62] = "4bba91e6-0e42-4e68-ab37-bfe2e29c39dd",
        [80] = "f6cfc7ba-d705-402a-af35-2e81e4ac28fe",
        [99] = "473c49bb-3a76-400e-8e41-ff4f2a05e7c5",
        [121] = "23f8d45c-4c9e-4010-b13e-65f40fa4ac8a",
        [144] = "614034b8-50a5-49bd-abd4-99c4f262395e",
        [168] = "a713db6a-665d-4d2e-9d95-5ffee820e0b5",
        [195] = "9e1c80d7-7b12-4d41-9f03-b802b3c2aa6a",
        [223] = "7275260c-e1e0-4fac-be56-6f70660eb93c",
        [252] = "01bceb5d-7696-4061-9ead-08dbf8204e10",
        [283] = "acc6784c-ab35-4160-bcfe-2bf314b8c7a3",
        [316] = "97fe9e66-b710-4424-8bc7-2ee6d146ad96",
        [350] = "ae0c2527-0768-4a06-ae5e-eaa397ed967e",
        [385] = "c37d5f1b-5466-4430-bafd-1a6080039960",
        [422] = "7af9e13c-1293-4bf2-ae4a-ff1f77609801",
        [461] = "0dd749dd-61de-45ef-86d7-9e4c126c8639",
        [501] = "9c0ce9e6-2dd7-4f0e-a868-850d2a0ce8a9",
        [542] = "c27de07b-0e67-45f5-bfd3-6b87813579bd",
        [585] = "7ae1d81e-9c85-4db4-9d92-31a460d4aa15",
        [629] = "6cc6768c-4751-412d-b5b4-5370bf469586",
        [675] = "e37e18c4-5c6b-42c6-8188-965dc248e73d",
        [722] = "e0633587-95a7-405b-9849-d8a4dbf987e3",
        [771] = "d0e64b14-7e29-40ca-9d67-fd1f32f5ac8b",
        [821] = "4f324f1e-034d-43c6-88c9-f830a5d055b1",
        [872] = "79df22c0-c798-4791-b524-1627f7228414",
        [925] = "183db255-c50f-4625-8e41-6eb6e9661502",
        [979] = "e6bfc30c-8fd3-4e0e-ac8b-f4a60335df1e",
        [1034] = "4db73989-e9ee-4741-8f49-f934396a314f",
        [1091] = "5e0f806f-6306-4ce5-9e23-c530314482b1",
        [1149] = "9c1193cd-d809-4c32-a87d-c406a5ba36c1",
        [1209] = "8deb5785-3a70-4406-9e7f-3ea754ed1cdd",
        [1270] = "91312b70-1b1a-4fb5-a4d7-cc55dfe934d7",
        [1332] = "fc8e7dad-a882-47da-b483-72358af00b37",
        [1396] = "476e49f8-879c-4b30-812f-d8ac5539876a",
        [1460] = "63db3e90-b209-4d74-b448-b5d431299303",
        [1527] = "6f779e4a-0056-42fb-a646-17d62a79645b",
        [1594] = "86ea9c8a-c0d7-4f03-9f25-2eb20891d36b",
        [1663] = "4ae25812-03cd-4cbb-b50b-3dcaf4894c2d",
        [1733] = "5e337cbe-7a64-48b8-8fcc-88c5c95aeabd",
        [1805] = "6052cc70-e110-4afc-aa1c-49b6857143c9",
        [1877] = "5c7a0cb4-40c3-4135-b584-1d428fbd17ed",
        [1951] = "4873c288-1d78-4055-865a-1f3db8af060a",
        [2027] = "2fb49938-e108-4dae-8e10-8761d5343fb2",
        [2103] = "2fac1b76-2f3d-4340-9f29-e51ca4cc8a4a",
        [2181] = "bfd76028-9f4b-4da8-a6f4-8662fdf0add5",
        [2261] = "0d9da3d1-74bd-4752-aaea-0fe48c502825",
    },
    Dragonborn2 = {
        [4] = "07f8a431-60a7-4ab7-9b6b-eccaedfd83a6",
        [13] = "a4ca4e28-8f8e-4474-90cd-b907adbc2867",
        [24] = "2729400c-d82e-4364-897e-61eb6c1da5ef",
        [37] = "973d1fae-5569-427a-ae0d-67de3004ce54",
        [52] = "dea6b194-8dd1-419e-997b-c827fe1570cd",
        [70] = "d3f9b0a9-2495-4e18-9cef-a4b2485a6dad",
        [88] = "7781f68a-3187-4679-ace5-777dcab83d74",
        [109] = "d350c323-57f2-4805-82dc-1f1667d264a1",
        [131] = "eb549a12-afb0-4c00-8725-31174d4e704d",
        [154] = "80399de7-02d2-4341-9a89-bf8681d8e86e",
        [179] = "d121a591-9ae3-430f-b480-ffe9e8c8dca3",
        [206] = "f21eb6e7-e321-426a-ad13-cec55721c2a9",
        [234] = "c7105e76-bc22-4bfa-8d94-f731239d6daf",
        [264] = "13278e21-6147-49df-b6cb-d7b558a40000",
        [295] = "fcd2cadc-0d3c-4bc6-87af-877f46f98aca",
        [328] = "8b7767e9-c95f-45b4-b244-05e26073f808",
        [362] = "d811a2c6-eadf-46b6-9bd5-ee6a3a61ac52",
        [397] = "d7fa5845-e905-4844-8307-3ea38f83d47e",
        [434] = "4edc86af-f8e5-4aa0-82f7-b85033e49d9b",
        [473] = "0eaf2f48-8261-431b-b1f5-d347878832e4",
        [512] = "d90f2fa5-6393-461f-adaa-499b79192c9d",
        [553] = "b04301dc-9b5e-4d7b-aa46-e24a08001bec",
        [596] = "ced5cb9f-194d-493c-9ece-0364f3fb44d2",
        [640] = "38652d9d-7df8-463f-bbe4-d88726cfaa80",
        [685] = "42917fdd-b7db-404a-b8a2-41243f1df21a",
        [731] = "276b8a93-2c60-4939-b96f-d55952aaa7ec",
        [779] = "f4f511ff-3774-48fd-9efb-7a536225eb67",
        [828] = "9467e76a-2679-4f1c-b399-383b3acdeecc",
        [878] = "c92c562a-25a4-4b8e-a2ee-e919336eae1f",
        [930] = "c7b90d58-29af-4119-84ed-3034ffd2e8b0",
        [983] = "054666f8-a429-405b-9d5d-a21949a953b9",
        [1037] = "d0dae6e0-ce79-460e-8005-9095f54ef446",
        [1093] = "77157e07-e4b8-4d1f-af52-a185b7637c58",
        [1150] = "e276d87f-e4e1-4cf2-8198-27996c041c9e",
        [1208] = "ee55f14c-1856-4dca-afbe-285b61f59ef0",
        [1267] = "494d71d2-2af7-4752-a944-59322e7903ff",
        [1328] = "33da213e-ff6e-44b9-b30a-a9b983f70135",
        [1390] = "90cc28b0-6069-4e22-9198-c629133f778e",
        [1453] = "8158fd9b-8eca-4c58-9140-9982468fd2fa",
        [1518] = "6123ddba-ea63-490b-bc0c-824c001d917d",
        [1583] = "c6346573-b56d-444b-a6d7-f01ab6a609c4",
        [1650] = "de906d16-0291-4d65-b6dd-93ab2335c584",
        [1718] = "57c8a1bd-e32c-4de5-9f06-a8b8aaeeeeed",
        [1788] = "3d4f2639-c155-4e39-b6b4-16f6812a4469",
        [1858] = "bd11b1b0-9e08-4529-9d3d-e74e9b52bb67",
        [1930] = "27f7ef3c-a26b-40f4-8c36-e0fd13c1a188",
        [2003] = "210cd65f-a74a-4dcf-ac95-3c9409a38cee",
        [2077] = "7e3abd1f-8e6b-44cc-a6aa-c9c5baf14a70",
        [2153] = "34a59b89-a2c3-4ea2-847e-0bf5caf23df7",
        [2230] = "ddc5e789-a701-41e6-8f01-7b75dc9cd861",
    },
}

---@type table
BellyTable = {
    -- prototype
    Test123 = {
        -- 2 == medium size. used when pred grows/shrinks
        DefaultSize = 2,
        -- if there are different bellies for different sexes
        Sexes = false,
        -- if Sexes is false, property 'Sex' is used. Otherwise Female/Male is used
        Sex = {
            -- if there are different bellies for different body types
            BodyShapes = false,
            -- name of the belly set
            Default = "Human1",
        },
    },
    Human = {
        DefaultSize = 2,
        Sexes = true,
        Female = {BodyShapes = true, Default = "Human1", Strong = "Human3"},
        Male = {BodyShapes = true, Default = "Human2", Strong = "Human4"},
    },
    Githyanki = {
        DefaultSize = 2,
        Sexes = true,
        Female = {BodyShapes = false, Default = "Human1"},
        Male = {BodyShapes = false, Default = "Human2"},
    },
    HalfOrc = {
        DefaultSize = 2,
        Sexes = true,
        Female = {BodyShapes = false, Default = "Human3"},
        Male = {BodyShapes = false, Default = "Human4"},
    },
    Dragonborn = {
        DefaultSize = 2,
        Sexes = true,
        Female = {BodyShapes = false, Default = "Dragonborn1"},
        Male = {BodyShapes = false, Default = "Dragonborn2"},
    },
}
---@type table<string, string>
RaceAliases = {
    Elf = "Human",
    Elf_HighElf = "Human",
    Elf_WoodElf = "Human",
    HalfElf = "Human",
    HalfElf_High = "Human",
    HalfElf_Wood = "Human",
    HalfElf_Drow = "Human",
    UndeadHighElfHidden = "Human",
    UndeadHighElfRevealed = "Human",
    Drow = "Human",
    Drow_LolthSworn = "Human",
    Drow_Seldarine = "Human",
    Humanoid = "Human",
    Aasimar = "Human",
    Tiefling = "Human",
    Tiefling_Asmodeus = "Human",
    Tiefling_Mephistopeles = "Human",
    Tiefling_Zariel = "Human",
    Dragonborn_Black = "Dragonborn",
    Dragonborn_Blue = "Dragonborn",
    Dragonborn_Brass = "Dragonborn",
    Dragonborn_Bronze = "Dragonborn",
    Dragonborn_Copper = "Dragonborn",
    Dragonborn_Gold = "Dragonborn",
    Dragonborn_Green = "Dragonborn",
    Dragonborn_Red = "Dragonborn",
    Dragonborn_Silver = "Dragonborn",
    Dragonborn_White = "Dragonborn",
}

---@type table
local DefaultCustomRacesBellies = {
    Test1 = {DefaultSize = 2, Sexes = false, Sex = {BodyShapes = false, Default = "Human1"}},
    Test2 = {
        DefaultSize = 2,
        Sexes = true,
        Female = {BodyShapes = true, Default = "Human1", Strong = "Human3"},
        Male = {BodyShapes = true, Default = "Human2", Strong = "Human4"},
    },
}
---@type table<string, string>
local DefaultCustomRaceAliases = {
    ["Human(Variant)"] = "Human",
    ["Human(Larian)"] = "Human",
    ["Test3"] = "Githyanki",
    ["Test4"] = "HalfOrc",
    ["Test5"] = "Dragonborn",
}
---@type table<string, table<GUIDSTRING, integer>>
local DefaultCustomBellySets = {
    ExampleBellySet = {
        ["e0d8e3d1-c34a-4539-a6f7-8ed2ae4d2374"] = 5,
        ["b69a552c-bfc6-434f-85a3-6b514755d77c"] = 14,
        ["50396633-f06d-4b8f-992f-ab06b4e9488c"] = 25,
        ["87a9ac08-8761-4895-af22-8f02ac6129a5"] = 38,
        ["e91907e8-55a0-4be9-8c96-ba9289f4fcf6"] = 53,
        ["f34ef939-f289-4e47-9c80-9a867b229402"] = 70,
        ["f5fbfd71-2541-4b20-b04b-c3d3650f9a80"] = 88,
        ["ebf1ea92-ad33-4c9e-9edc-34fbf265d938"] = 109,
        ["e4c0cedd-5e21-4d32-a3ea-8d21e246e2ef"] = 131,
        ["be7d596e-04b0-4571-b6a2-dd5639d55447"] = 154,
        ["d603c761-5eae-4e2a-828b-427bc273586c"] = 179,
        ["7b1a218c-a0f8-4b55-9546-e62b54bb20d7"] = 206,
        ["635e6ab9-0aba-458d-b1c4-bfa510016b8d"] = 234,
        ["1cc78903-4c8b-4912-886e-c546b50b60bb"] = 264,
        ["93ec8e00-c791-44bb-9da8-82e2a567b76e"] = 295,
        ["d77586f6-55d9-4a2f-a1c0-44e76f0a134d"] = 328,
        ["a96c75c4-6f5e-418d-b9b3-9a7abe2887d6"] = 362,
        ["097b06a3-562b-4ceb-afe5-a9f7032b7e3f"] = 398,
        ["ecf42b9b-6a67-4d9a-b73f-a4fbcacb3a8f"] = 435,
        ["bccd5300-12f3-4789-9bf3-48eecec15f12"] = 474,
        ["9f9c3b11-c8ca-4055-a39f-82392f254c2a"] = 513,
        ["8291ac94-e2fb-4fe9-89ad-bc0db574a024"] = 555,
        ["e3f91c22-1719-4554-a2f8-7b0dd5549ff2"] = 598,
        ["172b1c64-634c-4d65-a2cc-b2b7ba9ea1d1"] = 642,
        ["328f6a62-5602-4d4d-a82c-22dd9ea9fe7d"] = 687,
        ["9ce2bdf7-8b3f-4f55-9546-06fe3da5a327"] = 734,
        ["74a0ab60-7c57-495f-82ad-81ab3e29bd96"] = 782,
        ["cf593a57-c2b3-4a74-97f3-37a5c1bb59ec"] = 832,
        ["47b35bec-298f-4d06-8bff-2e6d1a344a73"] = 883,
        ["4ce28819-9253-4cdb-bdd6-f3e9ee6d1d97"] = 935,
        ["63b62164-68e5-48f5-8d13-ff6a5ae4d264"] = 988,
        ["5c03126e-6bab-42f2-a156-de9d496e8af5"] = 1043,
        ["a1533f2b-9a74-4a65-a936-938e4de3ebe3"] = 1099,
        ["c4e9fbe5-7c3b-478d-a9f4-f5428c34b802"] = 1157,
        ["db5dbc69-39e8-4f43-91cf-1a63332ebb0a"] = 1216,
        ["e73c8acb-4d88-46f0-8b91-0cff9842a441"] = 1276,
        ["5a51c715-ca3a-4422-b1d2-bd8bde537ae0"] = 1337,
        ["a6b75167-6d4a-4663-b343-fe264a47dcd9"] = 1400,
        ["c1278907-06e9-4500-b827-d6302c28595a"] = 1464,
        ["67d09988-345a-4e38-9f44-8b636c5e4cdf"] = 1529,
        ["a61b17bd-e63a-4759-ac31-8f81625923cd"] = 1595,
        ["fa965ddd-4c80-4f04-9e6f-edfae67cdd2f"] = 1663,
        ["28f2c855-6f8b-4426-9353-0227e74f768a"] = 1732,
        ["8fc1f0dc-55aa-49fe-8665-e032a512bd9f"] = 1802,
        ["55dcdc90-6aec-44f0-b737-30a0f8682266"] = 1874,
        ["8ade4cbd-9f97-47f0-a15b-fd35d06bcccd"] = 1946,
        ["4f17d5cc-175c-41ae-87bb-9eb5b159858e"] = 2020,
        ["02f6d61c-a7d2-4d28-add0-f9262242afc6"] = 2095,
        ["2339fd4b-ad6f-4281-af1d-b6d7a9f7ab20"] = 2172,
        ["1bede670-6174-423c-86bc-6f9b806e3961"] = 2249,
    },
}

---@type table
CustomRacesBellies = {}
---@type table
CustomRaceAliases = {}
---@type table<string, table<GUIDSTRING, integer>>
CustomBellySets = {}

local comment =
    "Here you can add custom races to give them bellies. CustomBellyTable allows for more precise customization, while CustomRaceAliases is simpler to use. Avalible belly sets: Human1-4, Dragonborn1-2. HalfOrc and Githyanki use human bellies. Which means if a custom race has only 2 human-like body types, you can use HalfOrc or Githyanki as the base race in CustomRaceAliases. If a race has 4 human-like body types, you can use Human as a base race. DefaultSize is the default size category of this race; 0 - tiny, 1 - small, 2 - medium, 3 - large, etc."
local BELLYCONFIG_PATH = "CustomRacesBellies.json"

function SP_SetupAllBellies()
    for k, v in pairs(CustomBellySets) do
        BellySets[k] = {}
        -- swap i and j and add to BellySets because json doesn't support int keys
        for i, j in pairs(v) do
            BellySets[k][j] = i
        end
    end
    for k, v in pairs(BellySets) do
        for i, j in pairs(v) do
            AllBellies[j] = true
        end
    end
end

function SP_SaveRaceBellyConfig()
    local myTable = {
        comment = comment,
        CustomRaceAliases = CustomRaceAliases,
        CustomRacesBellies = CustomRacesBellies,
        CustomBellySets = CustomBellySets,
    }
    local json = Ext.Json.Stringify(myTable)
    Ext.IO.SaveFile(BELLYCONFIG_PATH, json)
    _P("Config saved: \"Script Extender\\" .. BELLYCONFIG_PATH .. "\".")
end

function SP_ResetRaceBellyConfig()
    CustomRacesBellies = SP_Deepcopy(DefaultCustomRacesBellies)
    CustomRaceAliases = SP_Deepcopy(DefaultCustomRaceAliases)
    CustomBellySets = SP_Deepcopy(DefaultCustomBellySets)
    _P("Default custom race bellies loaded.")
end

function SP_ResetAndSaveRaceBellyConfig()
    SP_ResetRaceBellyConfig()
    SP_SaveRaceBellyConfig()
    SP_SetupAllBellies()
end

function SP_LoadRaceBellyConfigFromFile()
    SP_SetupAllBellies()
    local content = Ext.IO.LoadFile(BELLYCONFIG_PATH)
    if content == nil then
        _P(
            "Custom Race Belly Config not found. If this is your first time launching the game with this mod enabled, this is fine.")
        SP_ResetAndSaveRaceBellyConfig()
        return
    end

    _P("Custom Race Belly Config loaded: \"Script Extender\\" .. BELLYCONFIG_PATH .. "\".")

    local BellyConfig = Ext.Json.Parse(content)
    if BellyConfig.comment == nil or BellyConfig.CustomRaceAliases == nil or BellyConfig.CustomRacesBellies == nil or
        BellyConfig.CustomBellySets == nil then
        _F("Loaded broken Race Belly Config. Resetting.")
        SP_ResetAndSaveRaceBellyConfig()
    else
        CustomRaceAliases = SP_Deepcopy(BellyConfig.CustomRaceAliases)
        CustomRacesBellies = SP_Deepcopy(BellyConfig.CustomRacesBellies)
        CustomBellySets = SP_Deepcopy(BellyConfig.CustomBellySets)

    end

    local needResave = false

    -- this shit so ass
    -- check CustomRacesBellies
    for k, v in pairs(CustomRacesBellies) do
        if type(v) ~= "table" then
            CustomRacesBellies[k] = nil
            needResave = true
            _F(1)
        else
            if v.DefaultSize == nil or type(v.DefaultSize) ~= "number" then
                CustomRacesBellies[k] = nil
                needResave = true
                _F(2)
            elseif v.Sexes == nil or type(v.Sexes) ~= "boolean" then
                CustomRacesBellies[k] = nil
                needResave = true
                _F(3)
            elseif v.Sexes == false then
                if v.Sex == nil or type(v.Sex) ~= "table" then
                    CustomRacesBellies[k] = nil
                    needResave = true
                    _F(4)
                elseif v.Sex.BodyShapes == nil or type(v.Sex.BodyShapes) ~= "boolean" then
                    CustomRacesBellies[k] = nil
                    needResave = true
                    _F(5)
                elseif v.Sex.Default == nil or type(v.Sex.Default) ~= "string" then
                    CustomRacesBellies[k] = nil
                    needResave = true
                    _F(6)
                elseif v.Sex.BodyShapes == true and (v.Sex.Strong == nil or type(v.Sex.Strong) ~= "string") then
                    CustomRacesBellies[k] = nil
                    needResave = true
                    _F(7)
                end
            elseif v.Female == nil or type(v.Female) ~= "table" or v.Male == nil or type(v.Male) ~= "table" then
                CustomRacesBellies[k] = nil
                needResave = true
                _F(8)
            elseif v.Female.BodyShapes == nil or type(v.Female.BodyShapes) ~= "boolean" then
                CustomRacesBellies[k] = nil
                needResave = true
                _F(9)
            elseif v.Male.BodyShapes == nil or type(v.Male.BodyShapes) ~= "boolean" then
                CustomRacesBellies[k] = nil
                needResave = true
                _F(10)
            elseif v.Female.Default == nil or type(v.Female.Default) ~= "string" then
                CustomRacesBellies[k] = nil
                needResave = true
                _F(11)
            elseif v.Male.Default == nil or type(v.Male.Default) ~= "string" then
                CustomRacesBellies[k] = nil
                needResave = true
                _F(12)
            elseif v.Female.BodyShapes == true and (v.Female.Strong == nil or type(v.Female.Strong) ~= "string") then
                CustomRacesBellies[k] = nil
                needResave = true
                _F(13)
            elseif v.Male.BodyShapes == true and (v.Male.Strong == nil or type(v.Male.Strong) ~= "string") then
                CustomRacesBellies[k] = nil
                needResave = true
                _F(14)
            end
        end
    end

    -- if any Race Aliases are broken
    for k, v in pairs(CustomRaceAliases) do
        if type(k) ~= "string" or type(v) ~= "string" then
            CustomRaceAliases[k] = nil
            needResave = true
        end
    end

    for k, v in pairs(CustomBellySets) do
        if type(k) ~= "string" or type(v) ~= "table" then
            CustomBellySets[k] = nil
            needResave = true
        end
        for i, j in pairs(v) do
            if type(i) ~= "string" or type(j) ~= "number" then
                CustomBellySets[k][i] = nil
                needResave = true
            end
        end
    end

    if needResave then
        _F("Found and removed broken races from CustomRacesBellies, resaving!")
        SP_SaveRaceBellyConfig()
    end
    SP_SetupAllBellies()
end
