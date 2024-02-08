#version 330 core

// Atributos de vértice recebidos como entrada ("in") pelo Vertex Shader.
// Veja a função BuildTrianglesAndAddToVirtualScene() em "main.cpp".
layout (location = 0) in vec4 model_coefficients;
layout (location = 1) in vec4 normal_coefficients;
layout (location = 2) in vec2 texture_coefficients;
layout (location = 3) in vec3 material_Ka;
layout (location = 4) in vec3 material_Kd;
layout (location = 5) in vec3 material_Ks;
layout (location = 6) in int texture_Id;
uniform int vertex_lighting;

// Matrizes computadas no código C++ e enviadas para a GPU
uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

// Atributos de vértice que serão gerados como saída ("out") pelo Vertex Shader.
// ** Estes serão interpolados pelo rasterizador! ** gerando, assim, valores
// para cada fragmento, os quais serão recebidos como entrada pelo Fragment
// Shader. Veja o arquivo "shader_fragment.glsl".
out vec4 position_world;
out vec4 position_model;
out vec4 normal;
out vec2 texcoords;
out vec3 Ka;
out vec3 Kd;
out vec3 Ks;
flat out int textureId;
out vec4 color_vs;

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
uniform sampler2D TextureImage13;

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
#define SKYBOX_TID 13

// Constantes
#define M_PI   3.14159265358979323846
#define M_PI_2 1.57079632679489661923

void main()
{
    // A variável gl_Position define a posição final de cada vértice
    // OBRIGATORIAMENTE em "normalized device coordinates" (NDC), onde cada
    // coeficiente estará entre -1 e 1 após divisão por w.
    // Veja {+NDC2+}.
    //
    // O código em "main.cpp" define os vértices dos modelos em coordenadas
    // locais de cada modelo (array model_coefficients). Abaixo, utilizamos
    // operações de modelagem, definição da câmera, e projeção, para computar
    // as coordenadas finais em NDC (variável gl_Position). Após a execução
    // deste Vertex Shader, a placa de vídeo (GPU) fará a divisão por W. Veja
    // slides 41-67 e 69-86 do documento Aula_09_Projecoes.pdf.

    gl_Position = projection * view * model * model_coefficients;

    // Como as variáveis acima  (tipo vec4) são vetores com 4 coeficientes,
    // também é possível acessar e modificar cada coeficiente de maneira
    // independente. Esses são indexados pelos nomes x, y, z, e w (nessa
    // ordem, isto é, 'x' é o primeiro coeficiente, 'y' é o segundo, ...):
    //
    //     gl_Position.x = model_coefficients.x;
    //     gl_Position.y = model_coefficients.y;
    //     gl_Position.z = model_coefficients.z;
    //     gl_Position.w = model_coefficients.w;
    //

    // Agora definimos outros atributos dos vértices que serão interpolados pelo
    // rasterizador para gerar atributos únicos para cada fragmento gerado.

    // Posição do vértice atual no sistema de coordenadas global (World).
    position_world = model * model_coefficients;

    // Posição do vértice atual no sistema de coordenadas local do modelo.
    position_model = model_coefficients;

    vec4 origin = vec4(0.0, 0.0, 0.0, 1.0);
    vec4 camera_position = inverse(view) * origin;
    // Normal do vértice atual no sistema de coordenadas global (World).
    // Veja slides 123-151 do documento Aula_07_Transformacoes_Geometricas_3D.pdf

    normal = inverse(transpose(model)) * normal_coefficients;
    normal.w = 0.0;

    if(vertex_lighting == 0)
    {
        vec3 this_ka = material_Ka;
        vec3 this_kd = material_Kd;
        vec3 this_ks = material_Ks;
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
        vec4 l = object_id == SKYBOX_ID ? - normalize(camera_position - p) : normalize(camera_position - p);

        // Vetor que define o sentido da câmera em relação ao ponto atual.
        vec4 v = normalize(camera_position - p);

        // Vetor que define o sentido da reflexão especular ideal.
        vec4 r = normalize(-l + 2*dot(n,l)*n);

        // Coordenadas de textura obtidas do arquivo OBJ (se existirem!)
        // Parâmetros que definem as propriedades espectrais da superfície
        float q; // Expoente especular para o modelo de iluminação de Phong

        if( object_id == FINAL_PLANE_ID )
        {
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
        else if ( object_id == PLANE_ID )
        {
            this_kd = vec3(0.2,0.7,0.2);
            this_ks = vec3(0.01,0.01,0.01);
            this_ka = vec3(0.0,0.0,0.0);
            q = 5.0;
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

        if ( object_id == SPHERE_ID || object_id == SKYBOX_ID )
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
        else if ( object_id == PLANE_ID || object_id == FINAL_PLANE_ID ) {
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
            U = texture_coefficients.x;
            V = texture_coefficients.y;
        }

        // Obtemos a refletância difusa a partir da leitura da imagem TextureImage0
        vec3 Kd0 = texture(TextureImage0, vec2(U,V)).rgb;

        switch(texture_Id) {
            case NARUTO_TEXTURE_1_TID: Kd0 = texture(TextureImage1, vec2(U,V)).rgb; break;
            case NARUTO_TEXTURE_2_TID: Kd0 = texture(TextureImage2, vec2(U,V)).rgb; break;
            case NARUTO_TEXTURE_PUPILE_TID: Kd0 = texture(TextureImage3, vec2(U,V)).rgb; break;
            case BOX_TID: Kd0 = texture(TextureImage4, vec2(U,V)).rgb; break;
            case BRICK_TID: Kd0 = texture(TextureImage5, vec2(U,V)).rgb; break;
            case BRIDGE_TID: Kd0 = texture(TextureImage6, vec2(U,V)).rgb; break;
            case COW_TID: Kd0 = texture(TextureImage7, vec2(U,V)).rgb; break;
            case PIPE_TID: Kd0 = texture(TextureImage8, vec2(U,V)).rgb; break;
            case PIZZA_TID: Kd0 = texture(TextureImage9, vec2(U,V)).rgb; break;
            case WORLD_TID: Kd0 = texture(TextureImage11, vec2(U,V)).rgb; break;
            case CAR_TID: Kd0 = texture(TextureImage12, vec2(U,V)).rgb; break;
            case SKYBOX_TID: Kd0 = texture(TextureImage13, vec2(U,V)).rgb; break;
        }
        // Equação de Iluminação
        float lambert = max(0,dot(n,l));

        color_vs.rgb = Kd0 * (lambert_diffuse_term + 0.01) + ambient_term + phong_specular_term;

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
        color_vs.a = 1;

        // Cor final com correção gamma, considerando monitor sRGB.
        // Veja https://en.wikipedia.org/w/index.php?title=Gamma_correction&oldid=751281772#Windows.2C_Mac.2C_sRGB_and_TV.2Fvideo_standard_gammas
        color_vs.rgb = pow(color_vs.rgb, vec3(1.0,1.0,1.0)/2.2);

    }
    else
    {
        // Normal do vértice atual no sistema de coordenadas global (World).
        // Veja slides 123-151 do documento Aula_07_Transformacoes_Geometricas_3D.pdf.
        normal = inverse(transpose(model)) * normal_coefficients;
        normal.w = 0.0;

        // Coordenadas de textura obtidas do arquivo OBJ (se existirem!)
        texcoords = texture_coefficients;
        Ka = material_Ka;
        Kd = material_Kd;
        Ks = material_Ks;
        textureId = texture_Id;
        color_vs = vec4(0,0,0,0);
    }
}

