#version 330 core

// Atributos de fragmentos recebidos como entrada ("in") pelo Fragment Shader.
// Neste exemplo, este atributo foi gerado pelo rasterizador como a
// interpolação da posição global e a normal de cada vértice, definidas em
// "shader_vertex.glsl" e "main.cpp".
in vec4 position_world;
in vec4 normal;

// Posição do vértice atual no sistema de coordenadas local do modelo.
in vec4 position_model;

// Coordenadas de textura obtidas do arquivo OBJ (se existirem!)
in vec2 texcoords;

in vec3 Ka;
in vec3 Kd;
in vec3 Ks;
flat in int textureId;
in vec4 color_vs;

// Matrizes computadas no código C++ e enviadas para a GPU
uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

// Identificador que define qual objeto está sendo desenhado no momento

uniform int object_id;
#define CHARACTER_ID 0
#define PLANE_ID 1
#define SPHERE_ID 2
#define BLOCK_ID 3
#define PIZZA_ID 4
#define BOX_ID 5
#define PIPE_ID 6
#define COW_ID 7
#define BRIDGE_ID 8
#define BUNNY_ID 9
#define CAR_ID 10
#define FINAL_PLANE_ID 11
#define SKYBOX_ID 12

// Parâmetros da axis-aligned bounding box (AABB) do modelo
uniform vec4 bbox_min;
uniform vec4 bbox_max;

// Variáveis para acesso das imagens de textura
uniform sampler2D TextureImage0;
uniform sampler2D TextureImage1;
uniform sampler2D TextureImage2;
uniform sampler2D TextureImage3;
uniform sampler2D TextureImage4;
uniform sampler2D TextureImage5;
uniform sampler2D TextureImage6;
uniform sampler2D TextureImage7;
uniform sampler2D TextureImage8;
uniform sampler2D TextureImage9;
uniform sampler2D TextureImage10;
uniform sampler2D TextureImage11;
uniform sampler2D TextureImage12;

uniform int vertex_lighting;

// TID = TEXTURE_ID
#define GRAY_COLOR_TID 0
#define NARUTO_TEXTURE_1_TID 1
#define NARUTO_TEXTURE_2_TID 2
#define NARUTO_TEXTURE_PUPILE_TID 3
#define BOX_TID 4
#define BRICK_TID 5
#define BRIDGE_TID 6
#define COW_TID 7
#define PIPE_TID 8
#define PIZZA_TID 9
#define CHAO_TID 10
#define WORLD_TID 11
#define CAR_TID 12

// O valor de saída ("out") de um Fragment Shader é a cor final do fragmento.
out vec4 color;

// Constantes
#define M_PI   3.14159265358979323846
#define M_PI_2 1.57079632679489661923

void main()
{
    if(vertex_lighting == 0)
    {
        color = color_vs;

        return;
    }
    // Obtemos a posição da câmera utilizando a inversa da matriz que define o
    // sistema de coordenadas da câmera.
    vec4 origin = vec4(0.0, 0.0, 0.0, 1.0);
    vec4 camera_position = inverse(view) * origin;

    vec3 this_ka = Ka;
    vec3 this_kd = Kd;
    vec3 this_ks = Ks;

    // O fragmento atual é coberto por um ponto que percente à superfície de um
    // dos objetos virtuais da cena. Este ponto, p, possui uma posição no
    // sistema de coordenadas global (World coordinates). Esta posição é obtida
    // através da interpolação, feita pelo rasterizador, da posição de cada
    // vértice.
    vec4 p = position_world;

    // Normal do fragmento atual, interpolada pelo rasterizador a partir das
    // normais de cada vértice.
    vec4 n = normalize(normal);

    // Vetor que define o sentido da fonte de luz em relação ao ponto atual.
    vec4 l = normalize(camera_position - p);

    // Vetor que define o sentido da câmera em relação ao ponto atual.
    vec4 v = normalize(camera_position - p);

    // Vetor que define o sentido da reflexão especular ideal.
    vec4 r = normalize(-l + 2*dot(n,l)*n);

    // Parâmetros que definem as propriedades espectrais da superfície
    float q; // Expoente especular para o modelo de iluminação de Phong

    if(object_id == SKYBOX_ID) {
        this_kd = vec3(0.5,0.5,0.5);
        this_ks = vec3(0.02,0.02,0.02);
        this_ka = vec3(0.0,0.0,0.0);
        q = 5.0;
    }
    else if ( object_id == SPHERE_ID )
    {
        this_kd = vec3(0.8,0.4,0.08);
        this_ks = vec3(0.01,0.01,0.01);
        this_ka = vec3(0.4,0.2,0.04);
        q = 1.0;
    }
    else if ( object_id == BUNNY_ID )
    {
        // PREENCHA AQUI
        // Propriedades espectrais do coelho
        this_kd = vec3(0.08,0.4,0.8);
        this_ks = vec3(0.01,0.01,0.01);
        this_ka = vec3(0.04,0.2,0.4);
        q = 5.0;
    }
    else if ( object_id == PLANE_ID || object_id == FINAL_PLANE_ID )
    {
        this_kd = vec3(0.2,0.7,0.2);
        this_ks = vec3(0.01,0.01,0.01);
        this_ka = vec3(0.0,0.0,0.0);
        q = 4.0;
    }
    else // Objeto desconhecido = preto
    {
        q = 5.0;
    }

    // Espectro da fonte de iluminação
    vec3 I = vec3(1.0,1.0,1.0); // PREENCH AQUI o espectro da fonte de luz

    // Espectro da luz ambiente
    vec3 Ia = vec3(0.2,0.2,0.2); // PREENCHA AQUI o espectro da luz ambiente

    // Termo difuso utilizando a lei dos cossenos de Lambert
    vec3 lambert_diffuse_term = this_kd*I*max(0,dot(n,l)); // PREENCHA AQUI o termo difuso de Lambert

    // Termo ambiente
    vec3 ambient_term = this_ka*Ia; // PREENCHA AQUI o termo ambiente

    // Termo especular utilizando o modelo de iluminação de Phong
    vec3 phong_specular_term  = this_ks*I*pow(max(0,dot(n,v+l)),q); // PREENCH AQUI o termo especular de Phong

    // Coordenadas de textura U e V
    float U = 0.0;
    float V = 0.0;

    float radius = 1.0f;

    if ( object_id == SPHERE_ID || object_id == SKYBOX_ID)
    {
        // PREENCHA AQUI as coordenadas de textura da esfera, computadas com
        // projeção esférica EM COORDENADAS DO MODELO. Utilize como referência
        // o slides 134-150 do documento Aula_20_Mapeamento_de_Texturas.pdf.
        // A esfera que define a projeção deve estar centrada na posição
        // "bbox_center" definida abaixo.

        // Você deve utilizar:
        //   função 'length( )' : comprimento Euclidiano de um vetor
        //   função 'atan( , )' : arcotangente. Veja https://en.wikipedia.org/wiki/Atan2.
        //   função 'asin( )'   : seno inverso.
        //   constante M_PI
        //   variável position_model

        vec4 bbox_center = (bbox_min + bbox_max) / 2.0;

        vec4 pp = bbox_center + radius*(position_model - bbox_center)/length(position_model - bbox_center);

        vec4 pv = pp - bbox_center;

        float theta = atan(pv.x, pv.z);
        float phi = asin(pv.y/radius);

        U = (theta + M_PI)/(2*M_PI);
        V = (phi + M_PI_2)/(M_PI);
    }
    else if ( object_id == PLANE_ID || object_id == FINAL_PLANE_ID)
    {
        U = 0.4*(p.x - floor(p.x));
        V = 0.4*(p.z - floor(p.z));
    }
    else if ( object_id == BUNNY_ID ) {
            // Coordenadas de textura do plano, obtidas do arquivo OBJ.
        float minx = bbox_min.x;
        float maxx = bbox_max.x;

        float miny = bbox_min.y;
        float maxy = bbox_max.y;

        float minz = bbox_min.z;
        float maxz = bbox_max.z;

        U = (position_model.x - minx)/(maxx - minx);
        V = (position_model.y - miny)/(maxy - miny);
    }
    else
    {
        // Coordenadas de textura do plano, obtidas do arquivo OBJ.
        U = texcoords.x;
        V = texcoords.y;
    }

    // Obtemos a refletância difusa a partir da leitura da imagem TextureImage0
    vec3 Kd0 = texture(TextureImage0, vec2(U,V)).rgb;


    switch(textureId) {
        case NARUTO_TEXTURE_1_TID: Kd0 = texture(TextureImage1, vec2(U,V)).rgb; break;
        case NARUTO_TEXTURE_2_TID: Kd0 = texture(TextureImage2, vec2(U,V)).rgb; break;
        case NARUTO_TEXTURE_PUPILE_TID: Kd0 = texture(TextureImage3, vec2(U,V)).rgb; break;
        case BOX_TID: Kd0 = texture(TextureImage4, vec2(U,V)).rgb; break;
        case BRICK_TID: Kd0 = texture(TextureImage5, vec2(U,V)).rgb; break;
        case BRIDGE_TID: Kd0 = texture(TextureImage6, vec2(U,V)).rgb; break;
        case COW_TID: Kd0 = texture(TextureImage7, vec2(U,V)).rgb; break;
        case PIPE_TID: Kd0 = texture(TextureImage8, vec2(U,V)).rgb; break;
        case PIZZA_TID: Kd0 = texture(TextureImage9, vec2(U,V)).rgb; break;
        case CHAO_TID: Kd0 = texture(TextureImage10, vec2(U,V)).rgb; break;
        case WORLD_TID: Kd0 = texture(TextureImage11, vec2(U,V)).rgb; break;
        case CAR_TID: Kd0 = texture(TextureImage12, vec2(U,V)).rgb; break;
    }

    // Equação de Iluminação
    float lambert = max(0,dot(n,l));

    color.rgb = Kd0 * (lambert_diffuse_term + 0.01) + ambient_term + phong_specular_term;

    // NOTE: Se você quiser fazer o rendering de objetos transparentes, é
    // necessário:
    // 1) Habilitar a operação de "blending" de OpenGL logo antes de realizar o
    //    desenho dos objetos transparentes, com os comandos abaixo no código C++:
    //      glEnable(GL_BLEND);
    //      glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    // 2) Realizar o desenho de todos objetos transparentes *após* ter desenhado
    //    todos os objetos opacos; e
    // 3) Realizar o desenho de objetos transparentes ordenados de acordo com
    //    suas distâncias para a câmera (desenhando primeiro objetos
    //    transparentes que estão mais longe da câmera).
    // Alpha default = 1 = 100% opaco = 0% transparente
    color.a = 1;

    // Cor final com correção gamma, considerando monitor sRGB.
    // Veja https://en.wikipedia.org/w/index.php?title=Gamma_correction&oldid=751281772#Windows.2C_Mac.2C_sRGB_and_TV.2Fvideo_standard_gammas
    color.rgb = pow(color.rgb, vec3(1.0,1.0,1.0)/2.2);
}

