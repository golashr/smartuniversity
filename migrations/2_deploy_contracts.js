var University = artifacts.require("./University.sol");
var Institute = artifacts.require("./Institute.sol");
var Course = artifacts.require("./Course.sol");
var Batch = artifacts.require("./Batch.sol");
var Student = artifacts.require("./Student.sol");
var Certificate = artifacts.require("./Certificate.sol");
var UniController = artifacts.require("./UniController.sol");
var CertController = artifacts.require("./CertController.sol");

module.exports = function(deployer) {
  var student,university,institute,course,batch,certificate,uniController,certController;
  deployer.deploy(Student,"student1")
  .then((value)=>{
    return Student.deployed();
  })
  .then((instance)=>{
    student = instance;
    return deployer.deploy(University,"university1");
  })
  .then((value)=>{
    return University.deployed();
  })
  .then((instance)=>{
    university = instance;
    return deployer.deploy(Institute,university.address,"institute1");
  })
  .then((value)=>{
    return Institute.deployed();
  })
  .then((instance)=>{
    institute = instance;
    return deployer.deploy(Course,institute.address,"course1");
  })
  .then((value)=>{
    return Course.deployed();
  })
  .then((instance)=>{
    course = instance;
    return deployer.deploy(Batch,course.address,"batch1");
  })
  .then((value)=>{
    return Batch.deployed();
  })
  .then((instance)=>{
    batch = instance;
    return deployer.deploy(Certificate,batch.address,"certificate1",true,true,{overwrite: false});
  })
  .then((value)=>{
    return Certificate.deployed();
  })
  .then((instance)=>{
    certificate = instance;
    return deployer.deploy(UniController);
  })
  .then((value)=>{
    return UniController.deployed();
  })
  .then((instance)=>{
    uniController = instance;
    return deployer.deploy(CertController);
  })
  .then((value)=>{
    return CertController.deployed();
  })
  .then((instance)=>{
    certController = instance;
  })
  .catch((value)=>{
    //console.log("Done");
  })
};
