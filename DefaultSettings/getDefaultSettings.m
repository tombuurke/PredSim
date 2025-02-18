function [S] = getDefaultSettings(S,osim_path)
% --------------------------------------------------------------------------
% getDefaultSettings 
%   This functions sets default settings when the user didn't specify the
%   setting in main.m.
% 
% INPUT:
%   - S -
%   * setting structure S
%   
%   - osim_path -
%   * path to the osim model
%
% 
% OUTPUT:
%   - S -
%   * setting structure S
% 
% Original author: Bram Van Den Bosch
% Original date: 30/11/2021
%
% Last edit by: Bram Van Den Bosch
% Last edit date: 05/05/2023
% --------------------------------------------------------------------------

%% bounds

% minimal muscle activation, a number between 0 and 1
if ~isfield(S.bounds.a,'lower')
    S.bounds.a.lower = 0.05;
end

% minimal distance between orginins calcanei, in meters
if ~isfield(S.bounds.calcn_dist,'lower')
    S.bounds.calcn_dist.lower = 0.09;
end

% minimal distance between femur and hand orginins, in meters
if ~isfield(S.bounds.femur_hand_dist,'lower')
    S.bounds.femur_hand_dist.lower = sqrt(0.0324);
end

% minimal distance between origins toes, in meters
if ~isfield(S.bounds.toes_dist,'lower')
    S.bounds.toes_dist.lower = 0.10;
end

% minimal distance between origins tibiae, in meters
if ~isfield(S.bounds.tibia_dist,'lower')
    S.bounds.tibia_dist.lower = 0.11;
end

% upper bound on left step length, in meters
if ~isfield(S.bounds.SLL,'upper')
    S.bounds.SLL.upper = [];
end

% upper bound on right step length, in meters
if ~isfield(S.bounds.SLR,'upper')
    S.bounds.SLR.upper = [];
end

% lower bound on distance travelled, in meters
if ~isfield(S.bounds.dist_trav,'lower')
    S.bounds.dist_trav.lower = [];
end

% upper bound on final time, in seconds
if ~isfield(S.bounds.t_final,'upper')
    S.bounds.t_final.upper = 2;
end

% lower bound on final time, in seconds
if ~isfield(S.bounds.t_final,'lower')
    S.bounds.t_final.lower = 0.1;
end

% manually overwrite coordinate bounds
if ~isfield(S.bounds,'coordinates')
    S.bounds.coordinates = [];
end

%% metabolicE

% hyperbolic tangent smoothing factor (used in metabolic cost)
if ~isfield(S.metabolicE,'tanh_b')
    S.metabolicE.tanh_b = 10;
end

% name of the metabolic energy model used
if ~isfield(S.metabolicE,'model')
    S.metabolicE.model = 'Bhargava2004';
end

%% misc

% subject folder to save intermediate data
S.misc.subject_path = fullfile(S.misc.main_path,'Subjects',S.subject.name);

% maximal contraction velocity identifier --TO CHECK--
if ~isfield(S.misc,'v_max_s')
    S.misc.v_max_s = 0;
end

% type of gait simulation
if ~isfield(S.misc,'gaitmotion_type')
    S.misc.gaitmotion_type = 'HalfGaitCycle';
end

% type of equation to approximate musculo-skeletal geometry (moment arm and
% muscle-tendon lengths wrt. joint angle)
if ~isfield(S.misc,'msk_geom_eq')
    S.misc.msk_geom_eq = 'polynomials';
end

% minimal order of polynomial function
if ~isfield(S.misc.poly_order,'lower')
    S.misc.poly_order.lower = 3;
end

% maximal order of polynomial function
if ~isfield(S.misc.poly_order,'upper')
    S.misc.poly_order.upper = 9;
end

% name to save musculoskeletal geometry CasADi function
[~, model_name, ~] = fileparts(osim_path);
model_name = char(strrep(model_name, ' ', '_'));
S.misc.msk_geom_name = [model_name '_f_lMT_vMT_dM'];
if strcmp(S.misc.msk_geom_eq,'polynomials') 
    S.misc.msk_geom_name = [S.misc.msk_geom_name '_poly_',...
        num2str(S.misc.poly_order.lower) '_' num2str(S.misc.poly_order.upper)];
end

% default coordinate bounds used to approximate musculoskeletal geometry
if ~isfield(S.misc,'default_msk_geom_bounds')
    S.misc.default_msk_geom_bounds = 'default_msk_geom_bounds.csv';
end

% manually overwrite coordinate bounds used to approximate musculoskeletal geometry
if ~isfield(S.misc,'msk_geom_bounds')
    S.misc.msk_geom_bounds = [];
end

% rmse threshold for muscle-tendon length approximation
if ~isfield(S.misc,'threshold_lMT_fit')
    S.misc.threshold_lMT_fit = 0.003;
end

% rmse threshold for muscle-tendon momentarm approximation
if ~isfield(S.misc,'threshold_dM_fit')
    S.misc.threshold_dM_fit = 0.003;
end

% visualize IG and bounds
if ~isfield(S.misc,'visualize_bounds')
    S.misc.visualize_bounds = 0;
end

% damping Coefficient in contraction dynamics
if ~isfield(S.misc,'dampingCoefficient') || isempty(S.misc.dampingCoefficient)
    S.misc.dampingCoefficient = 0.01;
end

% assume constant pennation angle instead of constant width
if ~isfield(S.misc,'constant_pennation_angle')
    S.misc.constant_pennation_angle = 0;
end


%% post_process

% boolean to plot post processing results
if ~isfield(S.post_process,'make_plot')
    S.post_process.make_plot = 0;
end

% name used for saving the resultfiles (choose custom or structurized savename)
if ~isfield(S.post_process,'savename')
    S.post_process.savename = 'structured';
end

% filename of the result to post-process
if ~isfield(S.post_process,'result_filename')
    S.post_process.result_filename = [];
end

% rerun post-processing without solving OCP
if ~isfield(S.post_process,'rerun')
    S.post_process.rerun = 0;
end
if S.post_process.rerun && isempty(S.post_process.result_filename)
    error('Please provide the name of the result to post-process. (S.post_process.result_filename)')
end

% load w_opt and reconstruct R before rerunning the post-processing
% Advanced feature, for debugging only, you should not need this.
if ~isfield(S.post_process,'load_prev_opti_vars')
    S.post_process.load_prev_opti_vars = 0;
end
if S.post_process.load_prev_opti_vars && isempty(S.post_process.result_filename)
    error('Please provide the name of the result from which to load the optimization variables. (S.post_process.result_filename)')
end

%% solver

% solver algorithm used in the OCP
if ~isfield(S.solver,'linear_solver')
    S.solver.linear_solver = 'mumps';
end

% the power (10^-x) the error has to reach before the OCP can 
% be regarded as solved; a higher number gives a more precise answer, but
% requires more time
if ~isfield(S.solver,'tol_ipopt')
    S.solver.tol_ipopt = 4;
end

% maximal amount of itereations after wich the solver will stop
if ~isfield(S.solver,'max_iter')
    S.solver.max_iter = 10000;
end

% type of parallel computing
if ~isfield(S.solver,'parallel_mode')
    S.solver.parallel_mode = 'thread';
end

% ADD CHECK ST THIS IS ONLY  USED WHEN USING THREAD PARALLEL MODE?
% number of threads in parallel mode
if ~isfield(S.solver,'N_threads')
    S.solver.N_threads = 4;
end

% number of mesh intervals
if ~isfield(S.solver,'N_meshes')
    S.solver.N_meshes = 50;
    % by default, use double for full gait cycle
    if strcmp(S.misc.gaitmotion_type,'FullGaitCycle')
        S.solver.N_meshes = S.solver.N_meshes*2;
    end
end

% path to CasADi installation folder
if ~isfield(S.solver,'CasADi_path')
    S.solver.CasADi_path = [];
elseif ~isempty(S.solver.CasADi_path) && ~isfolder(S.solver.CasADi_path)
     error('Unable to find the path assigned to "S.solver.CasADi_path"')
end

if isempty(S.solver.CasADi_path) && S.solver.run_as_batch_job
    error('Running a simulation as batch job requires "S.solver.CasADi_path" to contain the CasADi installation folder')
end

%% subject

% folder path to store the subject specific results
if ~isfield(S.subject,'save_folder')
   error('Please provide a folder to store the results in. Specify the folder path in S.subject.save_folder.'); 
elseif ~isfolder(S.subject.save_folder)
    mkdir(S.subject.save_folder);
end

% name of the subject
if ~isfield(S.subject,'name')
    error('Please provide a name for this subject. This name will be used to store the results. Specify the name in S.subject.name.');
end

% mass of the subject, in kilograms
if ~isfield(S.subject,'mass')
   S.subject.mass = [];
end

% height of the pelvis for the initial guess, in meters
if ~isfield(S.subject,'IG_pelvis_y')
   S.subject.IG_pelvis_y = [];
end

% average velocity you want the model to have, in meters per second
if ~isfield(S.subject,'v_pelvis_x_trgt')
    S.subject.v_pelvis_x_trgt = 1.25;
end

% muscle strength
if ~isfield(S.subject,'muscle_strength')
    S.subject.muscle_strength = [];
end

% muscle stiffness
if ~isfield(S.subject,'muscle_pass_stiff_shift')
    S.subject.muscle_pass_stiff_shift = [];
end
if ~isfield(S.subject,'muscle_pass_stiff_scale')
    S.subject.muscle_pass_stiff_scale = [];
end

% tendon stiffness
if ~isfield(S.subject,'tendon_stiff_scale')
    S.subject.tendon_stiff_scale = [];
end

% initial guess inputs
% input should be a string: "quasi-random" or the path to a .mot file
if ~isfield(S.subject,'IG_selection')
    error('Please specify what you want to use as an initial guess. Either choose "quasi-random" or specify the path of a .mot file in S.subject.IG_selection.')
else
    [~,NAME,EXT] = fileparts(S.subject.IG_selection);
    if EXT == ".mot" && isfile(S.subject.IG_selection)
        disp(['Using ',char(S.subject.IG_selection), ' as initial guess.'])
        if ~isfield(S.subject,'IG_selection_gaitCyclePercent')
            error('Please specify what percent of gait cycle data is present in the initial guess file in S.subject.IG_selection_gaitCyclePercent. For example, use 50, 100, and 200 if the provided intial guess file has half a gait cycle, full gait cycle or two full gait cycles, respectively.')
        end
        if ((strcmp(S.misc.gaitmotion_type,'FullGaitCycle')) && (S.subject.IG_selection_gaitCyclePercent < 100))
            error('Cannot use an initial guess of an incomplete gait cycle for predictive simulation of a full gait cycle. Please adjust S.misc.gaitmotion_type or initial guess file.')
        elseif ((strcmp(S.misc.gaitmotion_type,'HalfGaitCycle')) && (S.subject.IG_selection_gaitCyclePercent < 50))
            error('Cannot use an initial guess of less than half gait gait cycle for predictive simulation of a half gait cycle. Please adjust S.misc.gaitmotion_type or initial guess file.')
        end
        
    elseif EXT == ".mot" && ~isfile(S.subject.IG_selection)
        error('The motion file path you specified does not exist. Check if the path exists or if you made a typo.')
        
    elseif EXT == "" && NAME == "quasi-random"
         disp('Using a quasi-random initial guess.')
         
    elseif EXT == "" && NAME ~= "quasi-random"
        error('Please specify what you want to use as an initial guess. Either choose "quasi-random" or specify the path of a .mot file.')
    end
end

% initial guess bounds
if ~isfield(S.subject,'IK_Bounds')
    S.subject.IK_Bounds = fullfile(S.misc.main_path,'OCP','IK_Bounds_Default.mot');
elseif ~isfile(S.subject.IK_Bounds)
    error('The motion file you specified in S.subject.IK_Bounds does not exist.')
end
disp([char(S.subject.IK_Bounds), ' will be used to determine bounds.'])

% type of mtp joint used in the model
if ~isfield(S.subject,'mtp_type')
    S.subject.mtp_type = ''; 
end

% muscle tendon properties
if ~isfield(S.subject,'scale_MT_params')
    S.subject.scale_MT_params = []; 
end

% muscle spasticity
if ~isfield(S.subject,'spasticity')
    S.subject.spasticity = []; 
elseif ~isempty(S.subject.spasticity)
    warning('spasticity is not yet implemented.')
end

% muscle coordination
if ~isfield(S.subject,'muscle_coordination')
    S.subject.muscle_coordination = []; 
elseif ~isempty(S.subject.muscle_coordination)
    warning('muscle coordination is not yet implemented.')
end

% damping coefficient for all degrees of freedon
if ~isfield(S.subject,'damping_coefficient_all_dofs')
    S.subject.damping_coefficient_all_dofs = 0.1; 
end

% different damping coefficient for specific degrees of freedon
if ~isfield(S.subject,'set_damping_coefficient_selected_dofs')
    S.subject.set_damping_coefficient_selected_dofs = []; 
end

% stiffness coefficient for all degrees of freedon
if ~isfield(S.subject,'stiffness_coefficient_all_dofs')
    S.subject.stiffness_coefficient_all_dofs = 0; 
end

% different stiffness coefficient for specific degrees of freedon
if ~isfield(S.subject,'set_stiffness_coefficient_selected_dofs')
    S.subject.set_stiffness_coefficient_selected_dofs = []; 
end

% limit torque coefficient for specific degrees of freedon
if ~isfield(S.subject,'set_limit_torque_coefficients_selected_dofs')
    S.subject.set_limit_torque_coefficients_selected_dofs = []; 
end

%% weights

% weight on metabolic energy rate
if ~isfield(S.weights,'E')
    S.weights.E = 500; 
end

% exponent for the metabolic energy rate
if ~isfield(S.weights,'E_exp')
    S.weights.E_exp = 2; 
end

% weight on joint accelerations
if ~isfield(S.weights,'q_dotdot')
    S.weights.q_dotdot = 50000; 
end

% weight on arm excitations
if ~isfield(S.weights,'e_arm')
    S.weights.e_arm = 10^6; 
end

% weight on passive torques
if ~isfield(S.weights,'pass_torq')
    S.weights.pass_torq = 1000; 
end

% damping can be included in the passive torques that go in the cost
% function
if ~isfield(S.weights,'pass_torq_includes_damping')
    S.weights.pass_torq_includes_damping = 0; 
end

% weight on muscle activations
if ~isfield(S.weights,'a')
    S.weights.a = 2000; 
end

% weight on slack controls
if ~isfield(S.weights,'slack_ctrl')
    S.weights.slack_ctrl = 0.001; 
end

%% .osim 2 dll

% settings for functions to conver .osim model to expression graph (.dll)
% file to solve inverse dynamics
if ~isfield(S,'Cpp2Dll')
    S.Cpp2Dll = [];
end

% select compiler for cpp projects 
%   Visual studio 2015: 'Visual Studio 14 2015 Win64'
%   Visual studio 2017: 'Visual Studio 15 2017 Win64'
%   Visual studio 2017: 'Visual Studio 16 2019'
%   Visual studio 2017: 'Visual Studio 17 2022'
if ~isfield(S.Cpp2Dll,'compiler')
    S.Cpp2Dll.compiler = findVisualStudioInstallation;
end

% Path with exectuables to create .cpp file. You can use the function 
% S.Cpp2Dll.PathCpp2Dll_Exe = InstallOsim2Dll_Exe(ExeDir) to download 
% this exectuable with the input 'ExeDir' to folder in which you want to
% install the executable. The output argument of this function gives
% you the path to the folder with the exectutable
if ~isfield(S.Cpp2Dll,'PathCpp2Dll_Exe')
    S.Cpp2Dll.PathCpp2Dll_Exe = [];
end

% Export 3D segment origins.
if ~isfield(S.Cpp2Dll,'export3DSegmentOrigins')
    S.Cpp2Dll.export3DSegmentOrigins = {'calcn_r', 'calcn_l', 'femur_r', 'femur_l',...
        'hand_r','hand_l', 'tibia_r', 'tibia_l', 'toes_r', 'toes_l'};
end

% If you want to choose the order of the joints and coordinate outputs
if ~isfield(S.Cpp2Dll,'jointsOrder')
    S.Cpp2Dll.jointsOrder = [];
end
if ~isfield(S.Cpp2Dll,'coordinatesOrder')
    S.Cpp2Dll.coordinatesOrder = [];
end

% Export total GRFs; If True, right and left 3D GRFs (in this order) are exported.
% % Set False or do not pass as argument to not export those variables.
if ~isfield(S.Cpp2Dll,'exportGRFs')
    S.Cpp2Dll.exportGRFs = true;
end

% Export separate GRFs. If True, right and left 3D GRFs (in this order) 
% are exported for each of the contact spheres.Set False or do not pass
% as argument to not export those variables.
if ~isfield(S.Cpp2Dll,'exportSeparateGRFs')
    S.Cpp2Dll.exportSeparateGRFs = true;
end

% # Export GRMs. If True, right and left 3D GRMs (in this order) are exported.
%  Set False or do not pass as argument to not export those variables.
if ~isfield(S.Cpp2Dll,'exportGRMs')
    S.Cpp2Dll.exportGRMs = true;
end

% Export contact sphere vertical deformation power. If True, right and left
% vertical deformation power of all contact spheres are exported.Set False
% or do not pass as argument to not export those variables.
if ~isfield(S.Cpp2Dll,'exportContactPowers')
    S.Cpp2Dll.exportContactPowers = true;
end

% 0: only warnings and errors
% 1: all information on building .dll file
if ~isfield(S.Cpp2Dll,'verbose_mode')
    S.Cpp2Dll.verbose_mode = true;
end 




end