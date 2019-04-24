exports.handler = async (event, context) => {

  let responseBody = {
    message: 'Hello from AWS::Lambda::Function and Terraform!'
  };

  return {
    statusCode: 200,
    body: JSON.stringify(responseBody)
  }
};